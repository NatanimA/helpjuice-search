module ApplicationHelper
  def format_date(date, format = "%B %d, %Y")
    return "N/A" if date.blank?
    
    date.strftime(format)
  end
  
  def format_datetime(datetime, format = "%B %d, %Y %-l:%M %p")
    return "N/A" if datetime.blank?
    
    datetime.strftime(format)
  end
  
  def active_class(path, active_class = "active")
    current_page?(path) ? active_class : ""
  end
  
  def sanitize_query(query, max_length = 255)
    return "" if query.blank?
    
    sanitized = ActionController::Base.helpers.strip_tags(query.to_s)
    
    sanitized.length > max_length ? sanitized[0...max_length] : sanitized
  end
end
