module AnalyticsHelper
  def format_analytics_data(analytics_hash, limit = nil)
    return [] if analytics_hash.blank?
    
    formatted = analytics_hash.map { |query, count| { query: query, count: count } }
                              .sort_by { |item| -item[:count] }
    
    limit ? formatted.first(limit) : formatted
  end
  
  def percentage_of_total(count, total, decimal_places = 1)
    return 0 if total == 0
    
    percentage = (count.to_f / total * 100)
    
    if decimal_places == 0
      percentage.round
    else
      factor = 10**decimal_places
      (percentage * factor).round / factor.to_f
    end
  end
end
