class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.integer :user_id, :null => false
      t.integer :alert_type, :null => false
      t.integer :alert_no, :null => false
      t.integer :item_id
      t.integer :trade_id
      t.integer :count, :default => 1, :null => false
      t.boolean :is_new, :default => true, :null => false

      t.timestamps
    end
  end
end
