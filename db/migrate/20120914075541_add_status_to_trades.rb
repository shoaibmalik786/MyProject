class AddStatusToTrades < ActiveRecord::Migration
  def up
    add_column :trades, :status, :string
  end
  
  def down
    remove_column :trades, :status
  end
  
end
