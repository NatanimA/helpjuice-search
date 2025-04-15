module Api
  module V1
    class InsightsController < ApplicationController
      def index
        begin
          page = [params[:page].to_i, 1].max
          per_page = [[params[:per_page].to_i, 10].max, 100].min
          
          query = SearchQuery.order(created_at: :desc)
          query = filter_by_dates(query)
          
          # Calculate offset and limit for manual pagination
          offset = (page - 1) * per_page
          
          # Get total count before applying offset/limit
          total = query.count
          
          # Apply offset and limit manually instead of using page/per
          insights = query.offset(offset).limit(per_page)
          
          if insights.empty?
            return render json: { 
              status: :ok,
              insights: [],
              meta: pagination_data(page, per_page, total)
            }
          end
          
          render json: {
            status: :ok,
            insights: serialize_insights(insights),
            meta: pagination_data(page, per_page, total)
          }
        rescue => e
          log_error("Failed to retrieve insights", e)
          error_response("Couldn't load insights data")
        end
      end
      
      def top_queries
        begin
          limit = [[params[:limit].to_i, 5].max, 50].min
          days = [[params[:days].to_i, 1].max, 365].min
          
          date_from = days.days.ago
          
          top_searches = SearchQuery
            .where("created_at >= ?", date_from)
            .group(:query)
            .order("count_all DESC")
            .limit(limit)
            .count
          
          render json: {
            status: :ok,
            period_days: days,
            queries: format_queries(top_searches)
          }
        rescue => e
          log_error("Failed to retrieve top queries", e)
          error_response("Couldn't load top queries")
        end
      end
      
      private
      
      def filter_by_dates(query)
        start_date = parse_date(params[:start_date])
        end_date = parse_date(params[:end_date])
        
        query = query.where("created_at >= ?", start_date.beginning_of_day) if start_date
        query = query.where("created_at <= ?", end_date.end_of_day) if end_date
        query
      end
      
      def parse_date(date_str)
        return nil if date_str.blank?
        
        Date.parse(date_str)
      rescue ArgumentError
        nil
      end
      
      def serialize_insights(insights)
        insights.map do |insight|
          {
            id: insight.id,
            query: insight.query,
            user: insight.user_identifier,
            completed: insight.completed,
            created: insight.created_at
          }
        end
      end
      
      def pagination_data(page, per_page, total)
        {
          page: page,
          per_page: per_page,
          total: total,
          pages: (total.to_f / per_page).ceil
        }
      end
      
      def format_queries(queries)
        queries.map { |query, count| { query: query, count: count } }
      end
      
      def log_error(message, exception)
        Rails.logger.error "#{message}: #{exception.message}"
      end
      
      def error_response(message)
        render json: { status: :error, message: message }, status: :internal_server_error
      end
    end
  end
end 