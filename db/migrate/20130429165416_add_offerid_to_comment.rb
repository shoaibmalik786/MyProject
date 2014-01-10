class AddOfferidToComment < ActiveRecord::Migration
  def change
  	add_column :comments, :offer_id, :integer
  end
end
