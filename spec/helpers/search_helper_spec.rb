require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SearchHelper. For example:
#
# describe SearchHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SearchHelper, type: :helper do
  describe "format_query_for_display" do
    it "truncates long queries" do
      long_query = "a" * 100
      expect(helper.format_query_for_display(long_query)).to eq("a" * 50 + "...")
    end
    
    it "doesn't truncate short queries" do
      query = "how to use rails"
      expect(helper.format_query_for_display(query)).to eq(query)
    end
    
    it "handles nil queries" do
      expect(helper.format_query_for_display(nil)).to eq("")
    end
  end
  
  describe "highlight_match" do
    it "highlights the matching part of a search result" do
      result = "Ruby on Rails tutorial"
      query = "rails"
      
      highlighted = helper.highlight_match(result, query)
      expect(highlighted).to include('<span class="highlight">Rails</span>')
    end
    
    it "handles case insensitive matching" do
      result = "Ruby on Rails tutorial"
      query = "RUBY"
      
      highlighted = helper.highlight_match(result, query)
      expect(highlighted).to include('<span class="highlight">Ruby</span>')
    end
    
    it "doesn't change the text when no match" do
      result = "Ruby on Rails tutorial"
      query = "python"
      
      highlighted = helper.highlight_match(result, query)
      expect(highlighted).to eq(result)
    end
    
    it "handles empty inputs gracefully" do
      expect(helper.highlight_match("", "query")).to eq("")
      expect(helper.highlight_match("text", "")).to eq("text")
      expect(helper.highlight_match(nil, "query")).to eq("")
    end
  end
end
