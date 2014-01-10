class AddGenderToopTipToUser < ActiveRecord::Migration
 def up
    add_column :users, :gender, :string, :default => "none"
    add_column :users, :tooltip, :boolean , :default => true 
  end
  
  def down
    remove_column :users, :gender
    remove_column :users, :tooltip
  end
end
