class AddAlertsFieldToWants < ActiveRecord::Migration
  def change
  	add_column :wants, :alert, :integer, :default => 1
  	execute "UPDATE wants SET alert = 0;"
  end
end
