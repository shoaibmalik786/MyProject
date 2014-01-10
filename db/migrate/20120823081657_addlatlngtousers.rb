class Addlatlngtousers < ActiveRecord::Migration
  def up
    add_column :users, :lat, :decimal, :precision => 15 , :scale => 10
    add_column :users, :lng, :decimal, :precision => 15 , :scale => 10
  end

  def down
    remove_column :users, :lat
    remove_column :users, :lng
  end
end
