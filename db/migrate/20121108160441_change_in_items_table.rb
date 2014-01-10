class ChangeInItemsTable < ActiveRecord::Migration
  def up
  	change_column :items, :is_open_to_all_offers, :boolean, :default => false, :null => false
  end

  def down
  	change_column :items, :is_open_to_all_offers, :boolean, :default => true, :null => false
  end
end
