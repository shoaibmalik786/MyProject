class AddImageUrlToCategories < ActiveRecord::Migration
   def up
    add_column :categories, :imageURL, :string
  end
  
  def down
    remove_column :categories, :imageURL
  end
end
