module AnalyticsHelper
  # Format the analytics hash into a sorted array of objects
  def format_analytics_data(analytics_hash, limit = nil)
    return [] if analytics_hash.blank?
    
    # Convert to array of {query, count} hashes sorted by count (descending)
    formatted = analytics_hash.map { |query, count| { query: query, count: count } }
                              .sort_by { |item| -item[:count] }
    
    # Apply limit if specified
    limit ? formatted.first(limit) : formatted
  end
  
  # Calculate percentage and round to specified decimal places
  def percentage_of_total(count, total, decimal_places = 1)
    return 0 if total == 0
    
    percentage = (count.to_f / total * 100)
    
    if decimal_places == 0
      percentage.round
    else
      # Round to specified decimal places
      factor = 10**decimal_places
      (percentage * factor).round / factor.to_f
    end
  end
end
