class AddChargeDetailsToTransaction < ActiveRecord::Migration
  def change
  	remove_column :transactions, :charge_id
  	add_column :transactions, :charge_id, :string
  	add_column :transactions, :card_id, :string
  	add_column :transactions, :transaction_status, :boolean
  end
end
