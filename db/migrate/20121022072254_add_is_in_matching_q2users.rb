class AddIsInMatchingQ2users < ActiveRecord::Migration
  def up
    add_column :users, :is_in_matching_q, :boolean, :default => false, :null => false
    add_column :users, :tradeya_match_ids, :text, :default => "", :null => false
    add_column :users, :person_match_ids, :text, :default => "", :null => false
  end

  def down
    remove_column :users, :is_in_matching_q
    remove_column :users, :tradeya_match_ids
    remove_column :users, :person_match_ids
  end
end
