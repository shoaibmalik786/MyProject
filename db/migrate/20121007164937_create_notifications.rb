class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id, :null => false
      t.integer :notification_type, :null => false
      t.integer :notification_no, :null => false
      t.text :data
      t.integer :count, :default => 1, :null => false
      t.boolean :sent, :default => false, :null => false 
      t.string :status, :default => "NEW", :null => false

      t.timestamps
    end
  end
end
