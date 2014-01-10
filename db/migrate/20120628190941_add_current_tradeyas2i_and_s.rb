class AddCurrentTradeyas2iAndS < ActiveRecord::Migration
  def up
    rename_column :info_and_settings, :current_spotlight, :current_tradeyas
    change_column :info_and_settings, :current_tradeyas, :string, :default => ""

    rename_column :info_and_settings, :exp_mail_sent_id, :exp_mail_sent_ids
    change_column :info_and_settings, :exp_mail_sent_ids, :string, :default => ""
  end
  def down
    change_column :info_and_settings, :current_tradeyas, :integer, :default => 0
    rename_column :info_and_settings, :current_tradeyas, :current_spotlight

    change_column :info_and_settings, :exp_mail_sent_ids, :integer, :default => 0
    rename_column :info_and_settings, :exp_mail_sent_ids, :exp_mail_sent_id
  end
end
