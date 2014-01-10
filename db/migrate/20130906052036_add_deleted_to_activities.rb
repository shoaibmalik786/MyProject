class AddDeletedToActivities < ActiveRecord::Migration
  def change
  	add_column :activities, :deleted, :boolean, :default => false, :null => false
  end
end
