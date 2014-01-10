class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.integer :user_id
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :country
      t.boolean :current
      t.float :lat
      t.float :ln

      t.timestamps
    end
  end
end
