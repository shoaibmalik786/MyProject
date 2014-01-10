class CreateItemWants < ActiveRecord::Migration
  def change
    create_table :item_wants do |t|
      t.integer :item_id
      t.integer :user_id
      t.string :title
      t.integer :category_id
      t.text :desc

      t.timestamps
    end
  end
end
