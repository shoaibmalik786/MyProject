class CreateItemPhotos < ActiveRecord::Migration
  def change
    create_table :item_photos do |t|
      t.integer :item_id
      t.has_attached_file :photo

      t.timestamps
    end
  end
end
