class AddWantMessageReminderToUser < ActiveRecord::Migration
  def change
  	add_column :users, :want_message_reminder, :boolean, :default => true
  end
end
