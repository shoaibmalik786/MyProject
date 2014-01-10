class AddConditionAndDeliveryToItems < ActiveRecord::Migration
  def change
    add_column :items, :condition, :integer, :default => 1
    add_column :items, :delivery, :integer, :default => 1
  end
end
