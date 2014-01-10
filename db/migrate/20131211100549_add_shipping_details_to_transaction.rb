class AddShippingDetailsToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :length, :float
    add_column :transactions, :height, :float
    add_column :transactions, :width, :float
    add_column :transactions, :weight, :float
    add_column :transactions, :ship_type_name, :string
    add_column :transactions, :ship_type_code, :string
    add_column :transactions, :ship_notes, :text
  end
end
