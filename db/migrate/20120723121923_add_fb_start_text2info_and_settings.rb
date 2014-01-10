class AddFbStartText2infoAndSettings < ActiveRecord::Migration
  def up
    change_table :info_and_settings do |t|
      t.boolean :sm_on_expired_tradeya, :default => false, :null => false
      t.text :fb_start_text, :default => "", :null => false
      t.text :home_pg_title_text, :default => "", :null => false
      t.string :mail_send_to_offerer_ids, :default => "", :null => false
      t.has_attached_file :home_pg_title_image
    end
  end

  def down
    remove_column :info_and_settings, :sm_on_expired_tradeya
    remove_column :info_and_settings, :fb_start_text
    remove_column :info_and_settings, :home_pg_title_text
    remove_column :info_and_settings, :mail_send_to_offerer_ids
    drop_attached_file :info_and_settings, :home_pg_title_image
  end
end
