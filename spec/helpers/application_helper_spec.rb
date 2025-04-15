require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "format_date" do
    it "formats date objects correctly" do
      date = Date.new(2024, 4, 15)
      expect(helper.format_date(date)).to eq("April 15, 2024")
    end
    
    it "formats datetime objects correctly" do
      datetime = DateTime.new(2024, 4, 15, 14, 30, 0)
      expect(helper.format_date(datetime)).to eq("April 15, 2024")
    end
    
    it "handles nil gracefully" do
      expect(helper.format_date(nil)).to eq("N/A")
    end
    
    it "uses custom format when provided" do
      date = Date.new(2024, 4, 15)
      expect(helper.format_date(date, "%Y-%m-%d")).to eq("2024-04-15")
    end
  end
  
  describe "format_datetime" do
    it "formats datetime objects with time" do
      datetime = DateTime.new(2024, 4, 15, 14, 30, 0)
      expect(helper.format_datetime(datetime)).to eq("April 15, 2024 2:30 PM")
    end
    
    it "handles nil gracefully" do
      expect(helper.format_datetime(nil)).to eq("N/A")
    end
    
    it "uses custom format when provided" do
      datetime = DateTime.new(2024, 4, 15, 14, 30, 0)
      expect(helper.format_datetime(datetime, "%Y-%m-%d %H:%M")).to eq("2024-04-15 14:30")
    end
  end
  
  describe "active_class" do
    it "returns active when current page matches" do
      allow(helper).to receive(:current_page?).with("/search").and_return(true)
      expect(helper.active_class("/search")).to eq("active")
    end
    
    it "returns empty string when current page doesn't match" do
      allow(helper).to receive(:current_page?).with("/search").and_return(false)
      expect(helper.active_class("/search")).to eq("")
    end
    
    it "accepts custom active class" do
      allow(helper).to receive(:current_page?).with("/search").and_return(true)
      expect(helper.active_class("/search", "current")).to eq("current")
    end
  end
  
  describe "sanitize_query" do
    it "removes HTML tags from queries" do
      expect(helper.sanitize_query("<script>alert('xss')</script>query")).to eq("alert('xss')query")
    end
    
    it "limits query length" do
      long_query = "a" * 300
      expect(helper.sanitize_query(long_query).length).to eq(255)
    end
    
    it "handles nil input" do
      expect(helper.sanitize_query(nil)).to eq("")
    end
  end
end 