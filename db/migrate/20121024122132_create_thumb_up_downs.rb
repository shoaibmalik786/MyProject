class CreateThumbUpDowns < ActiveRecord::Migration
  def change
    create_table :thumb_up_downs do |t|
      t.integer :user_id
      t.integer :item_id
      t.integer :person_id
      t.integer :match_type
      t.boolean :up_down
      t.string :token

      t.timestamps
    end
  end
end
