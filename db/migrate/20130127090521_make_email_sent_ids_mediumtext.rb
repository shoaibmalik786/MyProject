class MakeEmailSentIdsMediumtext < ActiveRecord::Migration
  def up
    change_column :info_and_settings, :exp_mail_sent_ids, :MEDIUMTEXT
    change_column :info_and_settings, :current_tradeyas, :MEDIUMTEXT
    change_column :info_and_settings, :offer_not_rated24h_mail_sent_ids, :MEDIUMTEXT
    change_column :info_and_settings, :selected_tradeya_mail_sent_ids, :MEDIUMTEXT
    change_column :info_and_settings, :mail_send_to_offerer_ids, :MEDIUMTEXT
    change_column :info_and_settings, :end_mail_sent_ids, :MEDIUMTEXT
    change_column :info_and_settings, :featured_tradeya_mail_sent_ids, :MEDIUMTEXT
    change_column :info_and_settings, :current_cat_tradeyas, :MEDIUMTEXT
    change_column :info_and_settings, :featured_tradeyas, :MEDIUMTEXT
    change_column :info_and_settings, :completed_trades, :MEDIUMTEXT
    change_column :info_and_settings, :newest_tradeyas, :MEDIUMTEXT
    change_column :info_and_settings, :goods_tradeyas, :MEDIUMTEXT
    change_column :info_and_settings, :services_tradeyas, :MEDIUMTEXT

    change_column :info_and_settings, :home_pg_title_image_file_name, :text
  end

  def down
    change_column :info_and_settings, :exp_mail_sent_ids, :string
    change_column :info_and_settings, :current_tradeyas, :string
    change_column :info_and_settings, :offer_not_rated24h_mail_sent_ids, :string
    change_column :info_and_settings, :selected_tradeya_mail_sent_ids, :string
    change_column :info_and_settings, :mail_send_to_offerer_ids, :string
    change_column :info_and_settings, :end_mail_sent_ids, :string
    change_column :info_and_settings, :featured_tradeya_mail_sent_ids, :string
    change_column :info_and_settings, :current_cat_tradeyas, :string
    change_column :info_and_settings, :featured_tradeyas, :string
    change_column :info_and_settings, :completed_trades, :string
    change_column :info_and_settings, :newest_tradeyas, :string
    change_column :info_and_settings, :goods_tradeyas, :string
    change_column :info_and_settings, :services_tradeyas, :string

    change_column :info_and_settings, :home_pg_title_image_file_name, :string
  end
end
