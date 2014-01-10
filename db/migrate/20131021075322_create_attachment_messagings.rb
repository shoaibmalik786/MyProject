class CreateAttachmentMessagings < ActiveRecord::Migration
  def change
    create_table :attachment_messagings do |t|
      t.string :attachment

      t.timestamps
    end
  end
end
