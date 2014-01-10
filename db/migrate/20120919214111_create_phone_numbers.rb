class CreatePhoneNumbers < ActiveRecord::Migration
  def change
    create_table :phone_numbers do |t|
      t.integer :user_id, :null => false
      t.string :phone_number, :null => false
      t.integer :verification_code, :null => false
      t.integer :user_input
      t.boolean :verified, :default => false, :null => false

      t.timestamps
    end
  end
end
