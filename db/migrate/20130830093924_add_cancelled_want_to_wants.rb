class AddCancelledWantToWants < ActiveRecord::Migration
  def change
  	add_column :wants, :cancelled_wants, :text
  end
end
