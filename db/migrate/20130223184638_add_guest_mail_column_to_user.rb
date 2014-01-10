class AddGuestMailColumnToUser < ActiveRecord::Migration
  def change
  	add_column :users, :guest_mail_sent_at, :datetime
  	add_column :users, :guest_user_token, :string
  end
end
