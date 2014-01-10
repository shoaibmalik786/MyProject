class AddIndexToMutualFriends < ActiveRecord::Migration
  def change
  	add_index :mutual_friends, :key
  end
end
