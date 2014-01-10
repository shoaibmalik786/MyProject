class AddTbToken2infoandsettin < ActiveRecord::Migration
  def change
    add_column :info_and_settings, :tb_token, :text
    add_column :info_and_settings, :tb_token_time, :datetime
  end
end
