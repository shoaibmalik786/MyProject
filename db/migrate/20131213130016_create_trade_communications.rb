class CreateTradeCommunications < ActiveRecord::Migration
  def change
    create_table :trade_communications do |t|
    	t.integer :passive_trade_id
    	t.integer :trade_id
    	t.string :communication_type
    	t.integer :owner_id
    	t.integer :recipient_id
    	t.text :communication_text
    	t.boolean :accepted_by_owner, :default => false, :null => false
    	t.boolean :accepted_by_recipient, :default => false, :null => false
    	t.boolean :viewed_by_owner, :default => false, :null => false
    	t.boolean :viewed_by_recipient, :default => false, :null => false
    	t.boolean :deleted, :default => false, :null => false

      t.timestamps
    end
  end
end
