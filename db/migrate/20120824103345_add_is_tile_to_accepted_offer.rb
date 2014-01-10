class AddIsTileToAcceptedOffer < ActiveRecord::Migration
  def change
    add_column :accepted_offers, :is_tile_image, :boolean, :default => true
  end
end
