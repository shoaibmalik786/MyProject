class AddMailSettingFieldsToUser < ActiveRecord::Migration
  def up
    add_column :users, :notify_tradeya_begins, :boolean, :default => true
    add_column :users, :notify_tradeya_timer, :boolean, :default => true
    add_column :users, :notify_tradeya_over, :boolean, :default => true
    add_column :users, :notify_received_offer, :boolean, :default => true
    add_column :users, :notify_offer_changed, :boolean, :default => true
    add_column :users, :notify_received_comments, :boolean, :default => true
    add_column :users, :notify_offer_accepted, :boolean, :default => true
    add_column :users, :notify_offer_turned_invalid, :boolean, :default => true
    add_column :users, :notify_tradeya_complete, :boolean, :default => true
    add_column :users, :notify_tradeya_expired_reactivated, :boolean, :default => true
    add_column :users, :notify_tradeya_postponed_reactivated, :boolean, :default => true
    add_column :users, :notify_tradeya_news_updates, :boolean, :default => true
    add_column :users, :notification_frequency, :integer, :default => 1
    add_column :users, :notify_via_email, :boolean , :default => true
    add_column :users, :notify_via_mobile, :boolean , :default => false 
  end
  
  def down
    remove_column :users, :notify_tradeya_begins
    remove_column :users, :notify_tradeya_timer
    remove_column :users, :notify_tradeya_over
    remove_column :users, :notify_received_offer
    remove_column :users, :notify_offer_changed
    remove_column :users, :notify_received_comments
    remove_column :users, :notify_offer_accepted
    remove_column :users, :notify_offer_turned_invalid
    remove_column :users, :notify_tradeya_complete
    remove_column :users, :notify_tradeya_expired_reactivated
    remove_column :users, :notify_tradeya_postponed_reactivated
    remove_column :users, :notify_tradeya_news_updates
    remove_column :users, :notification_frequency
    remove_column :users, :notify_via_email
    remove_column :users, :notify_via_mobile
  end
  
end
