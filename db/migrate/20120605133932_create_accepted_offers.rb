class CreateAcceptedOffers < ActiveRecord::Migration
  def change
    create_table :accepted_offers do |t|
      t.integer :trade_id
      t.integer :user_id
      t.boolean :recent_tradeya, :default => 0, :null => false

      t.timestamps
    end
  end
end
