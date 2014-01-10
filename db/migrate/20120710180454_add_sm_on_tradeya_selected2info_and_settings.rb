class AddSmOnTradeyaSelected2infoAndSettings < ActiveRecord::Migration
  def change
    add_column :info_and_settings, :sm_on_selected_tradeya, :boolean, :default => false, :null => false
    add_column :info_and_settings, :selected_tradeya_mail_sent_ids, :string, :default => ""
    add_column :info_and_settings, :sm_on_comment_by_other, :boolean, :default => false, :null => false
    add_column :info_and_settings, :sm_on_comment_by_pub, :boolean, :default => false, :null => false
  end
end
