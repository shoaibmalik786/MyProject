class AddIsGuestColumnToUser < ActiveRecord::Migration
  def change
  	add_column :users, :is_guest_user, :boolean, :default => false 
  end
end
