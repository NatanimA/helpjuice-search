Rails.application.routes.draw do
  # Analytics page
  get "analytics", to: "analytics#index", as: :analytics
  
  # Search routes
  get "search", to: "search#index", as: :search
  post "search/query", to: "search#query", as: :search_query
  get "search/query", to: "search#query"
  
  # Articles routes
  resources :articles, only: [:index, :show]
  
  # API routes for search
  namespace :api do
    namespace :v1 do
      post "search", to: "search#record"
      get "search_analytics", to: "analytics#user_analytics"
      get "global_analytics", to: "analytics#global_analytics"
      
      # Search suggestions
      get "suggestions", to: "search_suggestions#index"
      get "popular_searches", to: "search_suggestions#popular"
      
      # Search suggestions - additional routes to match the alternative controller name
      get "search_suggestions", to: "search_suggestions#index"
      get "search_suggestions/popular", to: "search_suggestions#popular"
      
      # Insights
      get "insights", to: "insights#index"
      get "top_queries", to: "insights#top_queries"
      
      # Search Queries
      post "search_queries", to: "search_queries#create"
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "search#index"
end
