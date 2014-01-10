class AddMainPhotoToItemPhoto < ActiveRecord::Migration
  def change
    add_column :item_photos, :main_photo, :boolean, :default => false
  end
end
