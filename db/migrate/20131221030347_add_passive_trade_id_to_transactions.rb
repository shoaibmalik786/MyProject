class AddPassiveTradeIdToTransactions < ActiveRecord::Migration
  def change
  	add_column :transactions, :passive_trade_id, :integer
  	add_column :transactions, :exchange_method, :integer
  end
end
