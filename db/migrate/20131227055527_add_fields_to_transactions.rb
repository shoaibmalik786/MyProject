class AddFieldsToTransactions < ActiveRecord::Migration
  def change
  	add_column :transactions, :exchange_date, :date
  	add_column :transactions, :exchange_time, :time
  	add_column :transactions, :exchange_note, :text
  end
end
