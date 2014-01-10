class AddIsSingleToItem < ActiveRecord::Migration
  def up
    add_column :items, :is_single_tradeya, :boolean, :default => true
  end
  
  def down
    remove_column :items, :is_single_tradeya
  end
end
