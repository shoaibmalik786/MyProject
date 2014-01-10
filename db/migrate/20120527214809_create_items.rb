class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title, :null  => false
      t.text :desc, :null  => false
      t.boolean :tod, :default => 0
      t.datetime :exp_date
      t.boolean :is_open_to_all_offers, :default => true, :null  => false
      t.string :open4categories
      t.integer :category_id
      t.integer :width, :default => 0, :null => false
      t.integer :height, :default => 0, :null => false

      t.timestamps
    end
  end
end
