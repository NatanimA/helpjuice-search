require 'rails_helper'

RSpec.describe SearchQuery, type: :model do
  describe "validations" do
    it { should validate_presence_of(:query) }
    it { should validate_presence_of(:user_identifier) }
    it { should validate_length_of(:query).is_at_most(255) }
  end
  
  describe "scopes" do
    let!(:completed_query1) { create(:search_query, query: "rails", completed: true, created_at: 1.day.ago) }
    let!(:completed_query2) { create(:search_query, query: "ruby", completed: true, created_at: 2.days.ago) }
    let!(:incomplete_query) { create(:search_query, query: "javascript", completed: false, created_at: 3.hours.ago) }
    
    describe ".completed" do
      it "returns only completed queries" do
        results = SearchQuery.completed
        expect(results).to include(completed_query1, completed_query2)
        expect(results).not_to include(incomplete_query)
        expect(results.count).to eq(2)
      end
    end
    
    describe ".incomplete" do
      it "returns only incomplete queries" do
        results = SearchQuery.incomplete
        expect(results).to include(incomplete_query)
        expect(results).not_to include(completed_query1, completed_query2)
        expect(results.count).to eq(1)
      end
    end
    
    describe ".by_date_range" do
      it "returns queries within the specified date range" do
        start_date = 1.5.days.ago
        end_date = 0.5.days.ago
        
        results = SearchQuery.by_date_range(start_date, end_date)
        expect(results).to include(completed_query1)
      end
      
      it "returns all queries when no dates are specified" do
        results = SearchQuery.by_date_range(nil, nil)
        expect(results.count).to eq(3)
      end
    end
    
    describe ".recent_from_user" do
      let(:user_id) { "user123" }
      let!(:recent_user_query) { create(:search_query, query: "recent", user_identifier: user_id, created_at: 1.minute.ago) }
      let!(:old_user_query) { create(:search_query, query: "old", user_identifier: user_id, created_at: 10.minutes.ago) }
      
      it "returns recent queries from the specified user" do
        results = SearchQuery.recent_from_user(user_id, 5.minutes.ago)
        expect(results).to include(recent_user_query)
        expect(results).not_to include(old_user_query)
      end
    end
  end
  
  describe ".track_query" do
    let(:user_id) { "user123" }
    let(:query_text) { "how to use rails" }
    
    context "when no recent queries exist" do
      it "creates a new search query record" do
        expect {
          search_query = SearchQuery.track_query(query_text, user_id)
          expect(search_query.persisted?).to be true
          expect(search_query.query).to eq(query_text)
          expect(search_query.user_identifier).to eq(user_id)
          expect(search_query.completed).to be false
        }.to change(SearchQuery, :count).by(1)
      end
    end
    
    context "when a recent query exists" do
      let!(:recent_query) { 
        create(:search_query, 
               query: "how to", 
               user_identifier: user_id, 
               completed: false,
               created_at: 30.seconds.ago) 
      }
      
      it "updates the existing query if it appears to be a continuation" do
        expect {
          search_query = SearchQuery.track_query(query_text, user_id)
          expect(search_query.id).to eq(recent_query.id)
          expect(search_query.query).to eq(query_text)
        }.not_to change(SearchQuery, :count)
      end
    end
    
    context "when a similar but unrelated recent query exists" do
      let!(:unrelated_query) { 
        create(:search_query, 
               query: "something completely different", 
               user_identifier: user_id, 
               completed: false,
               created_at: 30.seconds.ago) 
      }
      
      it "creates a new query instead of updating" do
        expect {
          SearchQuery.track_query(query_text, user_id)
        }.to change(SearchQuery, :count).by(1)
      end
    end
  end
  
  describe ".appears_complete?" do
    context "questions" do
      it "identifies question marks as likely complete" do
        query_text = "What is Ruby on Rails?"
        expect(SearchQuery.appears_complete?(query_text)).to be true
      end
    end
    
    context "short queries" do
      it "identifies very short queries as potentially incomplete" do
        query_text = "hi"
        expect(SearchQuery.appears_complete?(query_text)).to be false
      end
    end
    
    context "single words" do
      it "identifies single words as potentially incomplete" do
        query_text = "rails"
        expect(SearchQuery.appears_complete?(query_text)).to be false
      end
    end
    
    context "ending with prepositions or articles" do
      it "identifies queries ending with prepositions as incomplete" do
        query_text = "how to create with"
        expect(SearchQuery.appears_complete?(query_text)).to be false
      end
      
      it "identifies queries ending with articles as incomplete" do
        query_text = "how to use the"
        expect(SearchQuery.appears_complete?(query_text)).to be false
      end
    end
    
    context "balanced and complete sentences" do
      it "identifies complete sentences as likely complete" do
        query_text = "How to create a Rails application"
        expect(SearchQuery.appears_complete?(query_text)).to be true
      end
    end
  end
  
  describe ".user_stats" do
    let(:user_id) { "user123" }
    
    before do
      create(:search_query, query: "ruby", final_query: "ruby", user_identifier: user_id, completed: true, created_at: 1.day.ago)
      create(:search_query, query: "rails", final_query: "rails", user_identifier: user_id, completed: true, created_at: 2.days.ago)
      create(:search_query, query: "javascript", final_query: "javascript", user_identifier: "different_user", completed: true)
    end
    
    it "returns statistics for a specific user" do
      stats = SearchQuery.user_stats(user_id)
      
      expect(stats).to be_an(Array)
      expect(stats.size).to eq(2)
      expect(stats.first).to be_an(Array)
      expect(stats.map(&:first)).to include('ruby', 'rails')
      expect(stats.map(&:last)).to include(1)
    end
    
    it "returns limited results when a limit is specified" do
      stats = SearchQuery.user_stats(user_id, 1)
      
      expect(stats.size).to eq(1)
    end
  end
  
  describe ".global_stats" do
    before do
      create(:search_query, query: "ruby", final_query: "ruby", user_identifier: "user1", completed: true, created_at: 1.day.ago)
      create(:search_query, query: "rails", final_query: "rails", user_identifier: "user2", completed: true, created_at: 2.days.ago)
      create(:search_query, query: "ruby", final_query: "ruby", user_identifier: "user3", completed: true, created_at: 3.days.ago)
    end
    
    it "returns global statistics" do
      stats = SearchQuery.global_stats
      
      expect(stats).to be_an(Array)
      expect(stats.size).to be_between(1, 3)
      
      # Find the entry for "ruby" which should have a count of 2
      ruby_entry = stats.find { |entry| entry.first == "ruby" }
      expect(ruby_entry).not_to be_nil
      expect(ruby_entry.last).to eq(2)
    end
    
    it "returns limited results when a limit is specified" do
      stats = SearchQuery.global_stats(1)
      
      expect(stats.size).to eq(1)
    end
  end
end
