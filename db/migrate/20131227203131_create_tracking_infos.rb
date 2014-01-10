class CreateTrackingInfos < ActiveRecord::Migration
  def change
    create_table :tracking_infos do |t|
      t.integer :user_id
      t.string :affiliate
      t.string :code

      t.timestamps
    end
  end
end