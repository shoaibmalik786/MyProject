class AddGoodsServicesInterestsColumnToUser < ActiveRecord::Migration
  def up
    add_column :users, :goods_sub_cat_ids, :string, :default => ''
    add_column :users, :services_sub_cat_ids, :string, :default => ''
    add_column :users, :interests_sub_cat_ids, :string, :default => ''
    add_column :users, :wish, :string
  end
  
  def down
    remove_column :users, :goods_sub_cat_ids
    remove_column :users, :services_sub_cat_ids
    remove_column :users, :interests_sub_cat_ids
    remove_column :users, :wish
  end
end
