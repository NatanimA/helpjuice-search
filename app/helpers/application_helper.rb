module ApplicationHelper
  # Format a date with the default format or a custom format
  def format_date(date, format = "%B %d, %Y")
    return "N/A" if date.blank?
    
    date.strftime(format)
  end
  
  # Format a datetime with the default format or a custom format
  def format_datetime(datetime, format = "%B %d, %Y %-l:%M %p")
    return "N/A" if datetime.blank?
    
    datetime.strftime(format)
  end
  
  # Return an "active" class if the path matches the current page
  def active_class(path, active_class = "active")
    current_page?(path) ? active_class : ""
  end
  
  # Sanitize a search query by removing HTML tags and limiting length
  def sanitize_query(query, max_length = 255)
    return "" if query.blank?
    
    # Remove HTML tags and sanitize the query
    sanitized = ActionController::Base.helpers.strip_tags(query.to_s)
    
    # Truncate if longer than max_length
    sanitized.length > max_length ? sanitized[0...max_length] : sanitized
  end
end
