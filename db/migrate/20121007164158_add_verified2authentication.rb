class AddVerified2authentication < ActiveRecord::Migration
  def change
    add_column :authentications, :verified, :boolean, :default => true, :null => false
  end
end
