class AddSmRateOffer2infoAndSettings < ActiveRecord::Migration
  def change
    add_column :info_and_settings, :sm_on_24h_offer_not_rated, :boolean, :default => false, :null => false
    add_column :info_and_settings, :sm_on_o_submitted, :boolean, :default => false, :null => false
    add_column :info_and_settings, :offer_not_rated24h_mail_sent_ids, :string, :default => ""
  end
end
