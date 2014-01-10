class AddMoreInfoToRequestInfoItems < ActiveRecord::Migration
  def change
  	add_column :request_info_items, :more_photos, :boolean, :default => false
  	add_column :request_info_items, :additional_description, :boolean, :default => false
  	add_column :request_info_items, :verify_condition, :boolean, :default => false
  	add_column :request_info_items, :ask_question, :text
  end
end
