class AddCurrentToChargeCards < ActiveRecord::Migration
  def change
  	add_column :charge_cards, :current, :boolean
  end
end
