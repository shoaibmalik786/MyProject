class AddTbSessionId2infoAndSettings < ActiveRecord::Migration
  def change
    add_column :info_and_settings, :tb_session_id, :text
  end
end
