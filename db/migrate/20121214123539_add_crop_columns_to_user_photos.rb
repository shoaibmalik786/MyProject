class AddCropColumnsToUserPhotos < ActiveRecord::Migration
  def up
  	add_column :user_photos, :crop_x, :integer
  	add_column :user_photos, :crop_y, :integer
  	add_column :user_photos, :crop_w, :integer
  	add_column :user_photos, :crop_h, :integer
  end

  def down
  	remove_column :user_photos, :crop_x
  	remove_column :user_photos, :crop_y
  	remove_column :user_photos, :crop_w
  	remove_column :user_photos, :crop_h
  end
end
