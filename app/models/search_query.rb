class SearchQuery < ApplicationRecord
  validates :query, presence: true, length: { maximum: 255 }
  validates :user_identifier, presence: true

  scope :completed, -> { where(completed: true) }
  scope :for_user, ->(user_id) { where(user_identifier: user_id) }
  scope :incomplete, -> { where(completed: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_date_range, ->(start_date, end_date) {
    scope = all
    scope = scope.where("created_at >= ?", start_date.beginning_of_day) if start_date.present?
    scope = scope.where("created_at <= ?", end_date.end_of_day) if end_date.present?
    scope
  }
  scope :recent_from_user, ->(user_id, since) {
    where(user_identifier: user_id).where("created_at >= ?", since).order(created_at: :desc)
  }

  def self.track_query(query, user_id)
    return nil if query.blank? || user_id.blank?
    
    begin
      recent_query = in_progress_query(query, user_id)
      
      if recent_query
        recent_query.query = query
        recent_query.save
        return recent_query
      else
        new_query = new(query: query, user_identifier: user_id, completed: false)
        new_query.save
        return new_query
      end
    rescue => e
      Rails.logger.error "Error tracking query: #{e.message}"
      new_query = new(query: query, user_identifier: user_id, completed: false)
      new_query.save
      return new_query
    end
  end
  
  def finish!(final_text = nil)
    # Use the original query if final_text is blank
    final_text = query if final_text.blank?
    
    begin
      # Even if update fails, still call cleanup_sequence
      cleanup_sequence(final_text)
      update(completed: true, final_query: final_text)
      true
    rescue => e
      Rails.logger.error "Failed to finish search: #{e.message}"
      false
    end
  end
  
  def self.user_stats(user_id, limit = 20)
    return [] if user_id.blank?
    
    begin
      for_user(user_id)
        .completed
        .select(:final_query)
        .group(:final_query)
        .count
        .sort_by { |_, count| -count }
        .first(limit)
    rescue => e
      Rails.logger.error "Failed to get user stats: #{e.message}"
      []
    end
  end
  
  def self.global_stats(limit = 100)
    begin
      completed
        .select(:final_query)
        .group(:final_query)
        .count
        .sort_by { |_, count| -count }
        .first(limit)
    rescue => e
      Rails.logger.error "Failed to get global stats: #{e.message}"
      []
    end
  end
  
  def self.appears_complete?(text)
    return false if text.blank? || text.length < 5
    
    # Normalize text
    text = text.strip.gsub(/\s+/, ' ')
    words = text.split(/\s+/)
    word_count = words.length
    
    # Very short fragments are not complete sentences
    return false if word_count < 3
    
    # Definite sentence endings
    if text.match?(/[.!?]$/)
      return true
    end
    
    # Common complete phrases and patterns based on parts of speech
    phrase_patterns = {
      # Question patterns
      question_words: %w(who what where when why how),
      aux_question_starters: %w(is are was were do does did can could will would should),
      
      # Imperative sentence starters
      imperative_starters: %w(please find search look show tell give go make),
      
      # Content nouns that often appear at the end of search queries
      terminal_content_nouns: %w(guide tutorial examples documentation reference manual info information 
                               steps instructions process method algorithm strategy approach),
                               
      # Prepositions that rarely end complete sentences
      non_terminal_prepositions: %w(in on at by with for from to of),
      
      # Articles that rarely end complete sentences
      non_terminal_articles: %w(a an the),
      
      # Phrase completeness indicators - words that suggest completeness when they appear
      completeness_indicators: %w(and or but so because therefore thus however nevertheless)
    }
    
    # Check for incomplete sentences that end with prepositions or articles
    last_word = words.last.downcase.gsub(/[^\w]/, '')
    if phrase_patterns[:non_terminal_prepositions].include?(last_word) || 
       phrase_patterns[:non_terminal_articles].include?(last_word)
      return false
    end
    
    # Special case for "programming tutorial" and similar terminal words
    if phrase_patterns[:terminal_content_nouns].include?(last_word)
      return true
    end
    
    # Check if we have question structure
    first_word_lower = words.first.downcase
    if phrase_patterns[:question_words].include?(first_word_lower) || 
       phrase_patterns[:aux_question_starters].include?(first_word_lower)
      # Question should have subject and verb
      return word_count >= 4
    end
    
    # Check for imperative sentences
    if phrase_patterns[:imperative_starters].include?(first_word_lower)
      # Imperative needs an object
      return word_count >= 3
    end
    
    # Check for presence of completeness indicators in the middle
    middle_words = words[1...-1]
    middle_words.each do |word|
      clean_word = word.downcase.gsub(/[^\w]/, '')
      if phrase_patterns[:completeness_indicators].include?(clean_word)
        return true
      end
    end
    
    # Structure-based checks
    
    # Minimum length for a simple sentence with subject-verb-object
    if word_count >= 5
      return true
    end

    # If the query ends with a noun phrase (e.g., "The best programming language")
    # it's likely a complete search intent even without a verb
    if word_count >= 4 && !phrase_patterns[:non_terminal_prepositions].include?(last_word)
      return true
    end
    
    # Very short phrases need more scrutiny
    if word_count <= 3
      # Phrases like "The Importance of" - preposition suggests incompleteness
      if phrase_patterns[:non_terminal_prepositions].include?(last_word)
        return false
      end
      
      # Incomplete phrases like "The Best" - too vague
      if text.match?(/^the\s+[a-z]+$/i) && word_count == 2
        return false
      end
    end
    
    # Default: longer phrases are more likely to be complete
    text.length > 25
  end
  
  private
  
  def cleanup_sequence(final_text)
    self.class.cleanup_related_queries(user_identifier, final_text)
  end
  
  def self.in_progress_query(query, user_id)
    where(user_identifier: user_id)
      .incomplete
      .where("LOWER(query) = LOWER(?) OR LOWER(?) LIKE CONCAT(LOWER(query), '%') OR LOWER(query) LIKE CONCAT(LOWER(?), '%')", 
            query, query, query)
      .recent
      .first
  end
  
  def self.cleanup_related_queries(user_id, final_query)
    return if user_id.blank? || final_query.blank?
    
    begin
      # Delete incomplete queries in same sequence
      incomplete_count = delete_incomplete_queries(user_id, final_query)
      if incomplete_count > 0
        Rails.logger.info "Cleaned up #{incomplete_count} partial queries for user #{user_id}"
      end
      
      # Merge similar completed queries
      similar = merge_similar_queries(user_id, final_query)
      if similar > 0
        Rails.logger.info "Merged #{similar} similar queries to '#{final_query}'"
      end
    rescue => e
      Rails.logger.error "Error cleaning queries: #{e.message}"
    end
  end
  
  def self.delete_incomplete_queries(user_id, final_query)
    count = for_user(user_id)
      .incomplete
      .where("LOWER(?) LIKE CONCAT(LOWER(query), '%') OR LOWER(query) LIKE CONCAT(LOWER(?), '%')", 
            final_query, final_query)
      .delete_all
    
    count || 0
  end
  
  def self.merge_similar_queries(user_id, final_query)
    similar = for_user(user_id)
      .completed
      .where.not(final_query: final_query)
      .where("LOWER(final_query) LIKE CONCAT(LOWER(?), '%') OR LOWER(?) LIKE CONCAT(LOWER(final_query), '%')",
            final_query, final_query)
    
    count = similar.count
    similar.update_all(final_query: final_query) if count > 0
    count
  end
  
  # For backward compatibility
  class << self
    alias_method :find_or_initialize_for_user, :track_query 
    alias_method :analytics_for_user, :user_stats
    alias_method :overall_analytics, :global_stats
    alias_method :cleanup_and_consolidate, :cleanup_related_queries
    alias_method :cleanup_sequence, :cleanup_related_queries
  end
  
  # For backward compatibility
  alias_method :complete, :finish!
  alias_method :cleanup_related_queries, :cleanup_sequence
end
