class CreateItemVideos < ActiveRecord::Migration
  def change
    create_table :item_videos do |t|
      t.integer :item_id
      t.has_attached_file :video

      t.timestamps
    end
  end
end
