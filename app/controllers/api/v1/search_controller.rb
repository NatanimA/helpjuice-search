module Api
  module V1
    class SearchController < ApplicationController
      skip_before_action :verify_authenticity_token, only: [:record]
      
      def record
        user_id = request.remote_ip
        query = params[:query].to_s.strip
        
        if query.blank?
          Rails.logger.info "Skipping empty search from #{user_id}"
          return render json: { status: :empty, message: "Query cannot be empty" }
        end
        
        query = query[0...255] if query.length > 255
        
        is_final_from_client = params[:is_final].to_s == "true"
        force_final = params[:force_complete].to_s == "true"
        
        appears_complete = force_final ? true : SearchQuery.appears_complete?(query)
        
        log_completeness_analysis(query, appears_complete)
        
        is_final = force_final || (is_final_from_client && appears_complete)
        
        begin
          recent_query = find_recent_query(query, user_id)
          
          if recent_query
            search_query = recent_query
            search_query.query = query
          else
            search_query = SearchQuery.new(query: query, user_identifier: user_id, completed: false)
          end
          
          if !search_query.save
            error_msg = search_query.errors.full_messages.join(", ")
            Rails.logger.error "Could not save search query: #{error_msg}"
            return error_response(error_msg)
          end
          
          should_complete = force_final || (is_final_from_client && appears_complete)
          
          completeness_info = {
            appears_complete: appears_complete,
            is_final: should_complete,
            client_marked_final: is_final_from_client
          }
          
          if should_complete || force_final
            Rails.logger.info "RECORDING SEARCH: '#{query}' (#{user_id}) - appears complete: #{appears_complete}, force complete: #{force_final}"
            search_query.update(completed: true, final_query: query)
            completeness_status = :complete
          else
            if is_final_from_client && !appears_complete
              Rails.logger.info "REJECTED INCOMPLETE: '#{query}'"
              search_query.update(completed: false)
              completeness_status = :incomplete
            else
              completeness_status = :in_progress
            end
          end
          
          search_query.reload
          
          render json: { 
            status: :ok, 
            query: search_query.query, 
            completed: search_query.completed,
            id: search_query.id,
            completeness: completeness_status,
            analysis: completeness_info
          }
        rescue => e
          Rails.logger.error "Search error: #{e.message}\n#{e.backtrace.join("\n")}"
          error_response("Search processing failed")
        end
      end
      
      private
      
      def find_recent_query(query, user_id)
        SearchQuery.where(user_identifier: user_id)
          .where(completed: false)
          .where("created_at >= ?", 30.minutes.ago)
          .order(created_at: :desc)
          .first
      end
      
      def log_completeness_analysis(query, appears_complete)
        words = query.split(/\s+/)
        word_count = words.length
        
        Rails.logger.info "COMPLETENESS ANALYSIS: '#{query}'"
        Rails.logger.info "  - Word count: #{word_count}"
        Rails.logger.info "  - Character length: #{query.length}"
        Rails.logger.info "  - First word: #{words.first}"
        Rails.logger.info "  - Last word: #{words.last}"
        Rails.logger.info "  - Ends with punctuation: #{query.match?(/[.!?]$/)}"
        Rails.logger.info "  - Decision: #{appears_complete ? 'COMPLETE' : 'INCOMPLETE'}"
      end
      
      def error_response(message, status = :unprocessable_entity)
        render json: { status: :error, message: message }, status: status
      end
    end
  end
end 