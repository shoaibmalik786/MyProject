class AddLetsMeetServiseToItem < ActiveRecord::Migration
  def change
  	add_column :items, :lets_meet_service, :boolean, :default => false
  end
end
