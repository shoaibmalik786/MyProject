class CreateMutualFriends < ActiveRecord::Migration
  def change
    create_table :mutual_friends do |t|
      t.string :key
      t.text :fb_mutual_friends, :limit => 64.kilobytes + 1
      t.text :tw_mutual_friends, :limit => 64.kilobytes + 1
      t.text :ln_mutual_friends, :limit => 64.kilobytes + 1
      t.integer :fb_mutual_friends_count
      t.integer :tw_mutual_friends_count
      t.integer :ln_mutual_friends_count

      t.timestamps
    end
  end
end
