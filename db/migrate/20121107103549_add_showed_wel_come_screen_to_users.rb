class AddShowedWelComeScreenToUsers < ActiveRecord::Migration
  def up
  	add_column :users, :showed_onboarding, :boolean, :default => false, :null => false
  end

  def down
  	remove_column :users, :showed_onboarding
  end
end
