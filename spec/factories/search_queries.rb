FactoryBot.define do
  factory :search_query do
    query { "MyString" }
    final_query { "MyString" }
    user_identifier { "MyString" }
    completed { false }
  end
end
