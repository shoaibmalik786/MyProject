class MakeSessionDataMediumText < ActiveRecord::Migration
  def up
    change_column :sessions, :data, :MEDIUMTEXT
  end

  def down
    change_column :sessions, :data, :text
  end
end
