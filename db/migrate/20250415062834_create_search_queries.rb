class CreateSearchQueries < ActiveRecord::Migration[8.0]
  def change
    create_table :search_queries do |t|
      t.string :query
      t.string :final_query
      t.string :user_identifier
      t.boolean :completed

      t.timestamps
    end
  end
end
