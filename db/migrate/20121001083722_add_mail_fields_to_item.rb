class AddMailFieldsToItem < ActiveRecord::Migration
  def change
    add_column :items, :is_mail_sent_24, :boolean, :default => false
    add_column :items, :is_mail_sent_12, :boolean, :default => false
  end
end
