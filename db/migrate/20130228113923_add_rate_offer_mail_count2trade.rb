class AddRateOfferMailCount2trade < ActiveRecord::Migration
  def up
  	add_column :trades, :rate_offer_mail_count, :integer, :null => false, :default => 0
  end

  def down
  	remove_column :trades, :rate_offer_mail_count
  end  
end
