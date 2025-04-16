module SearchHelper
  def format_query_for_display(query, max_length = 50)
    return "" if query.blank?
    
    if query.length > max_length
      "#{query[0...max_length]}..."
    else
      query
    end
  end
  
  def highlight_match(text, query)
    return "" if text.blank?
    return text if query.blank?
    
    if text.downcase.include?(query.downcase)
      pattern = Regexp.new(Regexp.escape(query), Regexp::IGNORECASE)
      text.gsub(pattern) { |match| "<span class=\"highlight\">#{match}</span>" }
    else
      text
    end
  end
end
