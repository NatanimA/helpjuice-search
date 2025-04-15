require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the AnalyticsHelper. For example:
#
# describe AnalyticsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe AnalyticsHelper, type: :helper do
  describe "format_analytics_data" do
    it "converts analytics hash to array format" do
      analytics_hash = {
        "ruby on rails" => 3,
        "javascript" => 2
      }
      
      formatted = helper.format_analytics_data(analytics_hash)
      
      expect(formatted).to be_an(Array)
      expect(formatted.size).to eq(2)
      
      # First item should be the one with highest count
      expect(formatted.first[:query]).to eq("ruby on rails")
      expect(formatted.first[:count]).to eq(3)
      
      # Second item should have lower count
      expect(formatted.last[:query]).to eq("javascript")
      expect(formatted.last[:count]).to eq(2)
    end
    
    it "sorts analytics by count in descending order" do
      analytics_hash = {
        "javascript" => 1,
        "ruby on rails" => 5,
        "python" => 3
      }
      
      formatted = helper.format_analytics_data(analytics_hash)
      
      # Items should be in descending order by count
      expect(formatted.map { |item| item[:query] }).to eq(["ruby on rails", "python", "javascript"])
      expect(formatted.map { |item| item[:count] }).to eq([5, 3, 1])
    end
    
    it "limits results to specified maximum" do
      analytics_hash = {
        "ruby" => 10,
        "javascript" => 8,
        "python" => 6,
        "php" => 4,
        "go" => 2
      }
      
      formatted = helper.format_analytics_data(analytics_hash, 3)
      
      expect(formatted.size).to eq(3)
      expect(formatted.map { |item| item[:query] }).to eq(["ruby", "javascript", "python"])
    end
    
    it "handles empty input" do
      expect(helper.format_analytics_data({})).to eq([])
    end
    
    it "handles nil input" do
      expect(helper.format_analytics_data(nil)).to eq([])
    end
  end
  
  describe "percentage_of_total" do
    it "calculates percentage correctly" do
      expect(helper.percentage_of_total(25, 100)).to eq(25)
      expect(helper.percentage_of_total(1, 3)).to be_within(0.1).of(33.3)
    end
    
    it "handles zero total" do
      expect(helper.percentage_of_total(10, 0)).to eq(0)
    end
    
    it "rounds to specified decimal places" do
      expect(helper.percentage_of_total(1, 3, 0)).to eq(33)
      expect(helper.percentage_of_total(1, 3, 1)).to eq(33.3)
      expect(helper.percentage_of_total(1, 3, 2)).to eq(33.33)
    end
  end
end
