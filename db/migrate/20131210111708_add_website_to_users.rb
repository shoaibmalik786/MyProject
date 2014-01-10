class AddWebsiteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :website, :string
    add_column :users, :children, :boolean
    add_column :users, :shipping_notes, :text
  end
end
