class AddingColumnsInThumbsUPsDownsTable < ActiveRecord::Migration
  def up
  	rename_column  :thumb_up_downs,:up_down, :thumbs_up
  	add_column :thumb_up_downs, :thumbs_down_reason, :int 
  	add_column :thumb_up_downs, :thumbs_down_comment, :text
  end

  def down
  	rename_column  :thumb_up_downs,:thumbs_up, :up_down
  	remove_column :thumb_up_downs, :thumbs_down_reason
  	remove_column :thumb_up_downs, :thumbs_down_comment
  end
end
