module Api
  module V1
    class SearchQueriesController < ApplicationController
      def create
        begin
          user_id = params[:user_id].presence || request.remote_ip
          query_text = params[:query].to_s.strip
          page = [params[:page].to_i, 1].max
          
          # Validate query
          if query_text.blank?
            Rails.logger.info "Empty search query received from user #{user_id}"
            return render json: { status: :error, message: "Search query cannot be empty" }, status: :bad_request
          end
          
          # Truncate long queries
          max_query_length = 255
          if query_text.length > max_query_length
            original_query = query_text
            query_text = query_text.truncate(max_query_length)
            Rails.logger.warn "Query truncated for user #{user_id}: '#{original_query}' to '#{query_text}'"
          end
          
          # Create search query record
          search_query = SearchQuery.new(
            query: query_text, 
            user_identifier: user_id, 
            completed: false
          )
          
          unless search_query.save
            errors = search_query.errors.full_messages.join(", ")
            Rails.logger.error "Failed to create search query record: #{errors}"
            return render json: { status: :error, message: "Failed to save search query: #{errors}" }, status: :unprocessable_entity
          end
          
          Rails.logger.info "Search query created with ID: #{search_query.id}"
          
          # Perform search
          results = perform_search(query_text, page)
          
          # Mark query as completed
          search_query.update(completed: true)
          Rails.logger.info "Search query #{search_query.id} marked as completed"
          
          render json: {
            status: :ok,
            query: query_text,
            search_query_id: search_query.id,
            page: page,
            results: results
          }
        rescue => e
          Rails.logger.error "Search error: #{e.message}\n#{e.backtrace.join("\n")}"
          render json: { 
            status: :error, 
            message: "An error occurred while processing your search" 
          }, status: :internal_server_error
        end
      end
      
      private
      
      def perform_search(query, page)
        begin
          Rails.logger.info "Performing search for query: '#{query}', page: #{page}"
          # Implementation of your search logic here
          # This is a placeholder - replace with actual search implementation
          []
        rescue => e
          Rails.logger.error "Search execution error: #{e.message}"
          []
        end
      end
    end
  end
end 