class AddNotifyTradeyaLikedToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :notify_tradeya_liked, :boolean, :default => true
    add_column :users, :notify_tradeya_wanted, :boolean, :default => true
    add_column :users, :notify_tradeya_wanted_traded, :boolean, :default => true
    add_column :users, :notify_tradeya_liked_traded, :boolean, :default => true
  end
end