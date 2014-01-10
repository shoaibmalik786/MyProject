class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :trade_id
      t.integer :user_id
      t.integer :charge_id
      t.integer :address_id
      t.float :trans_charge
      t.float :ship_charge

      t.timestamps
    end
  end
end
