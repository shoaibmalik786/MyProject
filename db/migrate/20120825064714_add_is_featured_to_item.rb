class AddIsFeaturedToItem < ActiveRecord::Migration
  def change
    add_column :items, :is_featured, :boolean, :default => false
  end
end
