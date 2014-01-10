class AddShipItToItem < ActiveRecord::Migration
  def change
  	add_column :items, :ship_it, :boolean, :default => false
  end
end
