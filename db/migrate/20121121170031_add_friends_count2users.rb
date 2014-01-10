class AddFriendsCount2users < ActiveRecord::Migration
  def up
    add_column :users, :fb_friends_count, :integer, :default => 0, :null => false
    add_column :users, :tw_friends_count, :integer, :default => 0, :null => false
    add_column :users, :ln_friends_count, :integer, :default => 0, :null => false
  end

  def down
    remove_column :users, :fb_friends_count
    remove_column :users, :tw_friends_count
    remove_column :users, :ln_friends_count
  end
end
