class AddEndMailSentIds2infoandsettings < ActiveRecord::Migration
  def up
    add_column :info_and_settings, :end_mail_sent_ids, :string, :default => "", :null => false
    add_column :info_and_settings, :featured_tradeya_mail_sent_ids, :string, :default => "", :null => false
  end

  def down
    remove_column :info_and_settings, :end_mail_sent_ids
    remove_column :info_and_settings, :featured_tradeya_mail_sent_ids
  end
end
