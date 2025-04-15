class Article < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
  
  def self.search(query)
    return none if query.blank?
    
    clean_query = sanitize_query(query)
    
    begin
      if query.length > 3
        where("title ILIKE ? OR content ILIKE ?", "%#{clean_query}%", "%#{clean_query}%")
          .order(updated_at: :desc)
      else
        where("title ILIKE ?", "#{clean_query}%").order(updated_at: :desc)
      end
    rescue => e
      Rails.logger.error "Search error: #{e.message}"
      none
    end
  end
  
  def snippet(length = 150)
    content.to_s.truncate(length)
  end
  
  def self.recent_articles(limit = 10)
    order(created_at: :desc).limit(limit)
  end
  
  private
  
  def self.sanitize_query(query)
    query.to_s.gsub(/[\\%_]/) { |c| "\\#{c}" }
  end
end
