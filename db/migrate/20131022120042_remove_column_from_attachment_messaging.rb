class RemoveColumnFromAttachmentMessaging < ActiveRecord::Migration
  def up
  	remove_column :attachment_messagings, :attachment
  end

  def down
  	add_column :attachment_messagings, :attachment, :string
  end
end
