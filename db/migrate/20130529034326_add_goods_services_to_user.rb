class AddGoodsServicesToUser < ActiveRecord::Migration
	#columns added to imrove performance of user hover profile
  def change
  	add_column :users, :goods_str, :mediumtext 
  	add_column :users, :services_str, :mediumtext
  	add_column :users, :interests_str, :mediumtext
  	add_column :users, :tradeya_count, :integer, :default => 0
  end
end
