class AddPassiveTradeIdToTrades < ActiveRecord::Migration
  def change
  	add_column :trades, :passive_trade_id, :integer
  end
end
