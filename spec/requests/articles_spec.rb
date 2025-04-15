require 'rails_helper'

RSpec.describe "Articles", type: :request do
  let!(:article) { create(:article) }
  
  describe "GET /articles" do
    it "returns http success" do
      get "/articles"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /articles/:id" do
    it "returns http success" do
      get "/articles/#{article.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /articles/:id with invalid ID" do
    it "redirects to articles index" do
      get "/articles/999999" # Non-existent ID
      expect(response).to redirect_to(articles_path)
    end
  end
end
