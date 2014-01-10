class CreateContestData < ActiveRecord::Migration
	def change
		create_table :contest_data do |t|
			t.integer :user_id
			t.text :emails
			t.boolean :fb_share

			t.timestamps
		end
	end
end
