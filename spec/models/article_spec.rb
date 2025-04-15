require 'rails_helper'

RSpec.describe Article, type: :model do
  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
  end
  
  describe ".search" do
    before do
      create(:article, title: "Ruby on Rails Basics", 
             content: "Learn the fundamentals of Ruby on Rails framework")
      create(:article, title: "JavaScript for Beginners", 
             content: "A guide to getting started with JavaScript programming")
      create(:article, title: "Advanced CSS Techniques", 
             content: "Learn about flexbox, grid, and other CSS features")
    end
    
    context "when searching by title" do
      it "returns articles with matching title" do
        results = Article.search("Ruby")
        expect(results.count).to eq(1)
        expect(results.first.title).to include("Ruby")
      end
    end
    
    context "when searching by content" do
      it "returns articles with matching content" do
        results = Article.search("javascript")
        expect(results.count).to eq(1)
        expect(results.first.content).to include("JavaScript")
      end
    end
    
    context "when search has multiple matches" do
      it "returns all matching articles" do
        results = Article.search("Learn")
        expect(results.count).to eq(2)
      end
    end
    
    context "when search has no matches" do
      it "returns an empty array" do
        results = Article.search("Docker")
        expect(results).to be_empty
      end
    end
  end
end
