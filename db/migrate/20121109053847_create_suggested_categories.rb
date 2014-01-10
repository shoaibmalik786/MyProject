class CreateSuggestedCategories < ActiveRecord::Migration
  def change
    create_table :suggested_categories do |t|
    	t.integer :user_id
    	t.integer :parent_category_id
    	t.string :suggested_category
    	t.boolean :selected, :default => false
    	
      t.timestamps
    end
  end
end
