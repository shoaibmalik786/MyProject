class AddCurrentCategoryToInfoAndSettings < ActiveRecord::Migration
  def up
    add_column :info_and_settings, :current_category, :integer
    add_column :info_and_settings, :current_category_updated_at, :datetime
  end

  def down
    remove_column :info_and_settings, :current_category
    remove_column :info_and_settings, :current_category_updated_at
  end
end
