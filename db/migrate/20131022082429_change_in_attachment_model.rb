class ChangeInAttachmentModel < ActiveRecord::Migration
  def up
  	add_column :attachment_messagings, :notif_id, :integer
  end

  def down
  	remove_column :attachment_messagings, :notif_id
  end
end
