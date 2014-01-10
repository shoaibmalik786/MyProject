class CreateChargeCards < ActiveRecord::Migration
  def change
    create_table :charge_cards do |t|
      t.integer :user_id
      t.string :provider
      t.string :cust_id
      t.string :card_id
      t.string :last_4
      t.string :card_type
      t.string :exp_month
      t.string :exp_year

      t.timestamps
    end
  end
end
