require 'rails_helper'

RSpec.describe "analytics/index.html.erb", type: :view do
  context "with analytics data" do
    before do
      assign(:user_analytics, {
        "ruby on rails" => 3,
        "javascript" => 2
      })
      
      assign(:overall_analytics, {
        "ruby on rails" => 5,
        "javascript" => 3,
        "python" => 1
      })
      
      render
    end
    
    it "displays the analytics header" do
      assert_select "div.card-header h3", text: "Search Analytics"
    end
    
    it "displays the user analytics section" do
      assert_select "div.card-header h5", text: "Your Search Analytics"
      
      # Check for the table headers
      assert_select "th", text: "Search Query"
      assert_select "th", text: "Count"
      
      # Check for the presence of data, not the exact count
      assert_select "table tbody tr td", text: "ruby on rails"
      assert_select "table tbody tr td span.badge", text: "3"
      assert_select "table tbody tr td", text: "javascript"
      assert_select "table tbody tr td span.badge", text: "2"
    end
    
    it "displays the overall analytics section" do
      assert_select "div.card-header h5", text: "Overall Search Analytics"
      
      # Check for the table headers
      assert_select "th", text: "Search Query"
      assert_select "th", text: "Count"
      
      # Check for the presence of data, not the exact count
      assert_select "table tbody tr td", text: "ruby on rails"
      assert_select "table tbody tr td span.badge", text: "5"
      assert_select "table tbody tr td", text: "javascript"
      assert_select "table tbody tr td span.badge", text: "3"
      assert_select "table tbody tr td", text: "python"
      assert_select "table tbody tr td span.badge", text: "1"
    end
    
    it "includes the explanation about complete sentences" do
      assert_select "div.alert-info h5", text: "About Complete Sentences"
      assert_select "div.alert-info ul li", minimum: 4
    end
    
    it "contains analytics update JavaScript" do
      expect(rendered).to match(/fetchAndUpdateAnalytics/)
      expect(rendered).to match(/setInterval\(fetchAndUpdateAnalytics/)
    end
  end
  
  context "with empty analytics data" do
    before do
      assign(:user_analytics, {})
      assign(:overall_analytics, {})
      
      render
    end
    
    it "displays appropriate messages for empty data" do
      assert_select "div.alert-info", text: /You haven't made any completed searches yet/
      assert_select "div.alert-info", text: /No search data available yet/
    end
  end
end
