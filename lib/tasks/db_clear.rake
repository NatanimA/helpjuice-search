namespace :db do
  desc "Clear all search query records from the database"
  task clear_search_queries: :environment do
    count = SearchQuery.count
    SearchQuery.delete_all
    puts "Deleted #{count} search query records"
  end
end 