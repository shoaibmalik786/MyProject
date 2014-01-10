class CreateFeaturedTradeyas < ActiveRecord::Migration
  def change
    create_table :featured_tradeyas do |t|

    	t.datetime :startDate
    	t.datetime :endDate
    	t.integer :item_id

     	t.timestamps
    end
  end
end
