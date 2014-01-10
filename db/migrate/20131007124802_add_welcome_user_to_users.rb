class AddWelcomeUserToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :welcome_user, :boolean, :default => false, :null => false
  end
end
