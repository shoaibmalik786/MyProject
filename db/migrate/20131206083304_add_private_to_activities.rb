class AddPrivateToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :private, :int, :default => 0
  end
end
