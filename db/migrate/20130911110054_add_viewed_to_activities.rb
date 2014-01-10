class AddViewedToActivities < ActiveRecord::Migration
  def change
  	add_column :activities, :viewed_by_owner, :boolean, :default => false, :null => false
  	add_column :activities, :viewed_by_recipient, :boolean, :default => false, :null => false
  end
end
