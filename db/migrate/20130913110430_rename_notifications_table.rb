class RenameNotificationsTable < ActiveRecord::Migration
  def up
  	rename_table :notifications, :event_notifications
  end

  def down
  	rename_table :event_notifications, :notifications
  end
end
