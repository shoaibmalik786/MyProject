class AddUtmToTrackingInfo < ActiveRecord::Migration
  def change
    rename_column :tracking_infos, :code, :sbx_code
    add_column :tracking_infos, :utm_campaign, :string
    add_column :tracking_infos, :utm_source, :string
    add_column :tracking_infos, :utm_medium, :string
    add_column :tracking_infos, :utm_content, :string
    add_column :tracking_infos, :utm_term, :string
  end
end
