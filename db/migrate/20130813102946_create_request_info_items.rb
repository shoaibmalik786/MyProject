class CreateRequestInfoItems < ActiveRecord::Migration
  def change
    create_table :request_info_items do |t|
    	t.integer :user_id
      t.integer :item_id
      t.timestamps
    end
  end
end
