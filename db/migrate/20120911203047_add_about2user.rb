class AddAbout2user < ActiveRecord::Migration
  def change
    add_column :users, :display_name, :string, :default => "", :null => false
    add_column :users, :about, :text, :default => "", :null => false
  end
end
