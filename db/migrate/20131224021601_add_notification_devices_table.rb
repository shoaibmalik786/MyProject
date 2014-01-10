class AddNotificationDevicesTable < ActiveRecord::Migration
	def change
		create_table :notification_devices do |t|
		t.integer :device_type
		t.string :device_id
		t.integer :user_id
		t.timestamps
		end
	end
end
