class EmailFieldChanges < ActiveRecord::Migration
  def up
  	# Trades table
  	add_column :trades, :mail_sent_offer_ofr_on_ur_ofr, :boolean, :default => false
  	add_column :trades, :mail_sent_pub_rateoffer, :boolean, :default => false
  	# FeaturedTradeyas table
  	add_column :featured_tradeyas, :mail_sent_pub, :boolean, :default => false
  end

  def down
  	# Trades table
  	remove_column :trades, :mail_sent_offer_ofr_on_ur_ofr
  	remove_column :trades, :mail_sent_pub_rateOffer
  	# FeaturedTradeyas table
  	remove_column :featured_tradeyas, :mail_sent_pub
  end
end
