class AddMainPhotoToUserPhoto < ActiveRecord::Migration
  def change
  	add_column :user_photos, :user_main_photo, :boolean, :default => false
  end
end
