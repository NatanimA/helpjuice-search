require 'rails_helper'

RSpec.describe "Searches", type: :request do
  describe "GET /search" do
    it "returns http success" do
      get "/search"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /search/query" do
    it "returns valid JSON response" do
      post "/search/query", params: { query: "test" }
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("application/json")
      expect(JSON.parse(response.body)).to have_key("status")
    end
  end
end
