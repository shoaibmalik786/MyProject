class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.integer :item_id
      t.integer :offer_id

      t.timestamps
    end
  end
end
