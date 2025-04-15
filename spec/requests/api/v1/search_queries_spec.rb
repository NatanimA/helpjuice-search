require 'rails_helper'

RSpec.describe "Api::V1::SearchQueries", type: :request do
  let(:user_ip) { "192.168.1.1" }
  let(:valid_query) { "how to use ruby on rails" }
  
  before do
    # Mock the remote IP
    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(user_ip)
  end
  
  describe "POST /api/v1/search_queries" do
    context "with valid parameters" do
      it "creates a search query record and returns success" do
        post "/api/v1/search_queries", params: { query: valid_query }
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        expect(json["status"]).to eq("ok")
        expect(json["query"]).to eq(valid_query)
        expect(json["search_query_id"]).to be_present
        expect(json["page"]).to eq(1)
        
        # Verify the record was created and marked as completed
        search_query = SearchQuery.find(json["search_query_id"])
        expect(search_query).to be_present
        expect(search_query.query).to eq(valid_query)
        expect(search_query.completed).to eq(true)
        expect(search_query.user_identifier).to eq(user_ip)
      end
    end
    
    context "with custom user ID" do
      it "uses the provided user ID instead of IP" do
        custom_user_id = "user123"
        post "/api/v1/search_queries", params: { query: valid_query, user_id: custom_user_id }
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        search_query = SearchQuery.find(json["search_query_id"])
        expect(search_query.user_identifier).to eq(custom_user_id)
      end
    end
    
    context "with pagination" do
      it "accepts page parameter" do
        post "/api/v1/search_queries", params: { query: valid_query, page: 2 }
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        expect(json["page"]).to eq(2)
      end
    end
    
    context "with empty query" do
      it "returns an error response" do
        post "/api/v1/search_queries", params: { query: "" }
        
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        
        expect(json["status"]).to eq("error")
        expect(json["message"]).to include("Search query cannot be empty")
      end
    end
    
    context "with too long query" do
      it "truncates the query to 255 characters" do
        long_query = "a" * 300
        truncated_length = 255
        
        post "/api/v1/search_queries", params: { query: long_query }
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        search_query = SearchQuery.find(json["search_query_id"])
        expect(search_query.query.length).to eq(truncated_length)
      end
    end
    
    context "when validation error occurs" do
      it "returns an error response" do
        allow_any_instance_of(SearchQuery).to receive(:save).and_return(false)
        allow_any_instance_of(SearchQuery).to receive_message_chain(:errors, :full_messages, :join).and_return("Validation error")
        
        post "/api/v1/search_queries", params: { query: valid_query }
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        
        expect(json["status"]).to eq("error")
        expect(json["message"]).to include("Failed to save search query")
      end
    end
    
    context "when database error occurs" do
      it "returns an error response" do
        allow_any_instance_of(SearchQuery).to receive(:save).and_raise(StandardError.new("Database error"))
        
        post "/api/v1/search_queries", params: { query: valid_query }
        
        expect(response).to have_http_status(:internal_server_error)
        json = JSON.parse(response.body)
        
        expect(json["status"]).to eq("error")
        expect(json["message"]).to include("An error occurred")
      end
    end
  end
end 