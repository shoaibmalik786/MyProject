class AddHomePageDatailInInfoAndSettingsTable < ActiveRecord::Migration
  def up
  	add_column :info_and_settings, :current_cat_tradeyas, :string
  	add_column :info_and_settings, :featured_tradeyas, :string
  	add_column :info_and_settings, :completed_trades, :string
  	add_column :info_and_settings, :newest_tradeyas, :string
  	add_column :info_and_settings, :goods_tradeyas, :string
  	add_column :info_and_settings, :services_tradeyas, :string
  end

  def down
  	remove_column :info_and_settings, :current_cat_tradeyas
  	remove_column :info_and_settings, :featured_tradeyas
  	remove_column :info_and_settings, :completed_trades
  	remove_column :info_and_settings, :newest_tradeyas
  	remove_column :info_and_settings, :goods_tradeyas
  	remove_column :info_and_settings, :services_tradeyas
  end
  
end
