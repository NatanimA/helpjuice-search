module Api
  module V1
    class AnalyticsController < ApplicationController
      def user_analytics
        user_id = request.remote_ip
        Rails.logger.info "Getting search stats for #{user_id}"
        
        begin
          stats = SearchQuery.user_stats(user_id, 50)
          
          render json: {
            status: :ok,
            analytics: format_analytics(stats)
          }
        rescue => e
          Rails.logger.error "Analytics error: #{e.message}"
          render json: { status: :error, message: "Couldn't load analytics" }, 
                 status: :internal_server_error
        end
      end
      
      def global_analytics
        limit = [[params[:limit].to_i, 1].max, 100].min
        
        begin
          stats = SearchQuery.global_stats(limit)
          render json: { status: :ok, analytics: format_analytics(stats) }
        rescue => e
          Rails.logger.error "Global analytics error: #{e.message}"
          render json: { status: :error, message: "Couldn't load global analytics" }
        end
      end
      
      private
      
      def format_analytics(stats)
        stats.map { |query, count| { query: query, count: count } }
      end
    end
  end
end 