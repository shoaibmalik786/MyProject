class AddQuantityToItems < ActiveRecord::Migration
  def change
  	add_column :items, :quantity, :integer, :default => 1
  	add_column :items, :qty_unlimited, :boolean, :default => false
  end
end
