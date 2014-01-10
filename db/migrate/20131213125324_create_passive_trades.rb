class CreatePassiveTrades < ActiveRecord::Migration
  def change
    create_table :passive_trades do |t|
    	t.integer :item_id
    	t.integer :user_id
    	t.integer :trade_communication_id
    	t.string :status

      t.timestamps
    end
  end
end
