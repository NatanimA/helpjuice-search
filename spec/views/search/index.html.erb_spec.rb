require 'rails_helper'

RSpec.describe "search/index.html.erb", type: :view do
  before do
    assign(:articles, [
      create(:article, title: "Rails Basics", content: "Learn the basics of Rails framework"),
      create(:article, title: "Advanced Ruby", content: "Advanced Ruby programming techniques")
    ])
    assign(:user_id, "192.168.1.1")
    assign(:recent_searches, ["ruby on rails", "how to create an API"])
  end
  
  it "renders the search form" do
    render
    
    assert_select "div.card-header h3", text: "Search Articles"
    assert_select "input#search-input"
    assert_select "div#search-status"
    assert_select "div#search-results"
  end
  
  it "displays recent articles" do
    render
    
    assert_select "h4", text: "Recent Articles"
    assert_select "h5.card-title", count: 2
    assert_select "h5.card-title", text: "Rails Basics"
    assert_select "h5.card-title", text: "Advanced Ruby"
    assert_select "p.card-text", count: 2
  end
  
  it "contains the necessary JavaScript functionality" do
    render
    
    expect(rendered).to match(/document\.addEventListener\('DOMContentLoaded'/)
    expect(rendered).to match(/const searchInput = document\.getElementById\('search-input'\)/)
    expect(rendered).to match(/searchInput\.addEventListener\('input'/)
    expect(rendered).to match(/recordSearch\(query, false\)/)
    expect(rendered).to match(/searchArticles\(query\)/)
  end
end
