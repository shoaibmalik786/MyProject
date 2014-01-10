class AddFriendsToUser < ActiveRecord::Migration
  def up
    add_column :users, :fb_friends, :MEDIUMTEXT
    add_column :users, :tw_friends, :MEDIUMTEXT
    add_column :users, :ln_friends, :MEDIUMTEXT
  end

  def down
    remove_column :users, :fb_friends
    remove_column :users, :tw_friends
    remove_column :users, :ln_friends
  end
end
