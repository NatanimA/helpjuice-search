module SearchHelper
  # Format a search query for display, truncating if necessary
  def format_query_for_display(query, max_length = 50)
    return "" if query.blank?
    
    if query.length > max_length
      "#{query[0...max_length]}..."
    else
      query
    end
  end
  
  # Highlight matching parts of search result text
  def highlight_match(text, query)
    return "" if text.blank?
    return text if query.blank?
    
    # Case insensitive matching
    if text.downcase.include?(query.downcase)
      # Regex with case insensitive match
      pattern = Regexp.new(Regexp.escape(query), Regexp::IGNORECASE)
      text.gsub(pattern) { |match| "<span class=\"highlight\">#{match}</span>" }
    else
      text
    end
  end
end
