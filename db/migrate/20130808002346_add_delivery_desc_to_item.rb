class AddDeliveryDescToItem < ActiveRecord::Migration
  def change
    add_column :items, :delivery_desc, :text
  end
end
