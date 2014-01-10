class UpdateUserFields4Categories < ActiveRecord::Migration
  def up
    change_column :users, :goods_sub_cat_ids, :MEDIUMTEXT, :default => "", :null => false
    change_column :users, :services_sub_cat_ids, :MEDIUMTEXT, :default => "", :null => false
    change_column :users, :interests_sub_cat_ids, :MEDIUMTEXT, :default => "", :null => false
  end

  def down
    change_column :users, :goods_sub_cat_ids, :string
    change_column :users, :services_sub_cat_ids, :string
    change_column :users, :interests_sub_cat_ids, :string
  end
end
