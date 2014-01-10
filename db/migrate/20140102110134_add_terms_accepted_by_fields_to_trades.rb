class AddTermsAcceptedByFieldsToTrades < ActiveRecord::Migration
  def change
  	add_column :trades, :terms_accepted_by_item_user, :boolean, :default => false, :null => false
  	add_column :trades, :terms_accepted_by_offer_user, :boolean, :default => false, :null => false
  end
end
