namespace :search_analytics do
  desc "Fix incomplete search records and ensure proper analytics"
  task fix_records: :environment do
    puts "Fixing incomplete search records..."
    
    # Find incomplete searches that should be marked complete
    incomplete_count = SearchQuery.incomplete.where("LENGTH(query) > 10").update_all(
      completed: true, 
      final_query: SearchQuery.arel_table[:query]
    )
    
    puts "  Completed #{incomplete_count} previously incomplete searches"
    
    # Find searches without final_query value
    missing_final_count = SearchQuery.completed.where(final_query: nil).update_all(
      "final_query = query"
    )
    
    puts "  Fixed #{missing_final_count} searches with missing final_query value"
    
    # Report on analytics status
    total_searches = SearchQuery.count
    completed_searches = SearchQuery.completed.count
    user_counts = SearchQuery.group(:user_identifier).count
    
    puts "Analytics status:"
    puts "  Total search records: #{total_searches}"
    puts "  Completed searches: #{completed_searches} (#{(completed_searches.to_f / total_searches * 100).round(2)}%)"
    puts "  Unique users: #{user_counts.size}"
    puts "  Top 5 users by search count:"
    
    user_counts.sort_by { |_, count| -count }.first(5).each do |user_id, count|
      user_complete = SearchQuery.completed.where(user_identifier: user_id).count
      puts "    #{user_id}: #{count} searches (#{user_complete} completed)"
    end
    
    puts "Done!"
  end
end 