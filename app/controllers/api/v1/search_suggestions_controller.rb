module Api
  module V1
    class SearchSuggestionsController < ApplicationController
      def index
        query = params[:query].to_s.strip
        
        if query.blank?
          return render json: { status: "ok", suggestions: [] }
        end
        
        begin
          suggestions = find_suggestions(query, 10)
          
          render json: {
            status: "ok",
            query: query,
            suggestions: suggestions
          }
        rescue => e
          Rails.logger.error "Suggestions error: #{e.message}"
          render json: { status: "error", suggestions: [] }
        end
      end
      
      def popular
        requested_limit = [[params[:limit].to_i, 5].max, 20].min
        
        begin
          all_suggestions = popular_searches(20)
          
          actual_suggestions = all_suggestions.first(requested_limit)
          
          render json: {
            status: "ok",
            suggestions: actual_suggestions
          }
        rescue => e
          Rails.logger.error "Popular suggestions error: #{e.message}"
          render json: { status: "error", suggestions: [] }
        end
      end
      
      private
      
      def find_suggestions(query, limit = 10)
        return [] if query.blank?
        
        suggestions = SearchQuery
          .where("query ILIKE ?", "%#{escape_like(query)}%")
          .where(completed: true)
          .group(:query)
          .order("count_all DESC")
          .limit(limit)
          .count
          .keys
          .uniq
          
        suggestions.first(limit)
      end
      
      def popular_searches(limit = 10)
        SearchQuery
          .where(completed: true)
          .group(:query)
          .order("count_all DESC")
          .limit(limit)
          .count
          .keys
      end
      
      def escape_like(string)
        string.gsub(/[\\%_]/) { |c| "\\#{c}" }
      rescue
        ""
      end
    end
  end
end 