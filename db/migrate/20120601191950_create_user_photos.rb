class CreateUserPhotos < ActiveRecord::Migration
  def change
    create_table :user_photos do |t|
      t.integer :user_id
      t.has_attached_file :photo

      t.timestamps
    end
  end
end
