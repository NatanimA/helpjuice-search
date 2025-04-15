class SearchController < ApplicationController
  def index
    @user_id = request.remote_ip
    @recent_searches = recent_user_searches(@user_id)
    @articles = Article.recent_articles(10)
  end
  
  def query
    query = params[:query].to_s.strip
    
    if query.blank?
      return render json: {
        status: :error,
        message: "Search query cannot be empty"
      }
    end
    
    begin
      results = Article.search(query).limit(20)
      render json: {
        status: :ok,
        results: results.map { |article| {
          id: article.id,
          title: article.title,
          content: article.snippet
        }}
      }
    rescue => e
      Rails.logger.error "Search failed: #{e.message}"
      render json: {
        status: :error,
        message: "Something went wrong with your search"
      }
    end
  end
  
  private
  
  def recent_user_searches(user_id)
    SearchQuery.for_user(user_id)
               .completed
               .recent
               .limit(5)
               .pluck(:final_query)
               .uniq
  rescue => e
    Rails.logger.error "Failed to load recent searches: #{e.message}"
    []
  end
end
