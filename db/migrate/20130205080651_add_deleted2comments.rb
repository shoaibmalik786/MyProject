class AddDeleted2comments < ActiveRecord::Migration
  def change
    add_column :comments, :deleted, :boolean, :default => false, :null => false
  end
end
