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
    final_text = query if final_text.blank?
    
    begin
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
    
    text = text.strip.gsub(/\s+/, ' ')
    words = text.split(/\s+/)
    word_count = words.length
    
    return false if word_count < 3
    
    if text.match?(/[.!?]$/)
      return true
    end
    
    phrase_patterns = {
      question_words: %w(who what where when why how which whose whom),
      aux_question_starters: %w(is are was were do does did can could will would should may might must has have had),
      
      imperative_starters: %w(please find search look show tell give go make create list explain describe compare analyze define solve implement),
      
      terminal_content_nouns: %w(guide tutorial examples documentation reference manual info information 
                               steps instructions process method algorithm strategy approach 
                               software application app program framework library code package module
                               technique system protocol standard best-practices practices tool toolkit
                               article blog post video course lecture presentation report review analysis
                               solution problem error issue bug feature requirement specification),
                               
      non_terminal_prepositions: %w(in on at by with for from to of through between among without during before after against under over),
      
      non_terminal_articles: %w(a an the),

      non_terminal_conjunctions: %w(and or nor),
      
      completeness_indicators: %w(and or but so because therefore thus however nevertheless since although though despite while unless if when),
      
      technical_domains: %w(programming coding development software web mobile cloud data database api server frontend backend devops testing),
      
      programming_languages: %w(javascript python java ruby c# php go rust typescript swift kotlin scala r)
    }
    
    last_word = words.last.downcase.gsub(/[^\w]/, '')
    if phrase_patterns[:non_terminal_prepositions].include?(last_word) || 
       phrase_patterns[:non_terminal_articles].include?(last_word) ||
       phrase_patterns[:non_terminal_conjunctions].include?(last_word)
      return false
    end
    
    if phrase_patterns[:terminal_content_nouns].include?(last_word) ||
       phrase_patterns[:technical_domains].include?(last_word) ||
       phrase_patterns[:programming_languages].include?(last_word)
      return true
    end
    
    first_word_lower = words.first.downcase
    if phrase_patterns[:question_words].include?(first_word_lower) || 
       phrase_patterns[:aux_question_starters].include?(first_word_lower)
      return word_count >= 4
    end
    
    if phrase_patterns[:imperative_starters].include?(first_word_lower)
      return word_count >= 3
    end
    
    middle_words = words[1...-1]
    middle_words.each do |word|
      clean_word = word.downcase.gsub(/[^\w]/, '')
      if phrase_patterns[:completeness_indicators].include?(clean_word)
        return true
      end
    end
    
    if word_count >= 5
      return true
    end

    if word_count >= 4 && !phrase_patterns[:non_terminal_prepositions].include?(last_word)
      return true
    end
    
    if word_count <= 3
      if phrase_patterns[:non_terminal_prepositions].include?(last_word)
        return false
      end
      
      if text.match?(/^the\s+[a-z]+$/i) && word_count == 2
        return false
      end
      
      if phrase_patterns[:programming_languages].include?(last_word) || 
         phrase_patterns[:technical_domains].include?(last_word)
        return true
      end
    end
    
    text.length > 20
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
      incomplete_count = delete_incomplete_queries(user_id, final_query)
      if incomplete_count > 0
        Rails.logger.info "Cleaned up #{incomplete_count} partial queries for user #{user_id}"
      end
      
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
  
  class << self
    alias_method :find_or_initialize_for_user, :track_query 
    alias_method :analytics_for_user, :user_stats
    alias_method :overall_analytics, :global_stats
    alias_method :cleanup_and_consolidate, :cleanup_related_queries
    alias_method :cleanup_sequence, :cleanup_related_queries
  end
  
  alias_method :complete, :finish!
  alias_method :cleanup_related_queries, :cleanup_sequence
end
