class AddEmailSentToFollows < ActiveRecord::Migration
  def change
  	add_column :follows, :email_sent, :boolean, :default => false, :null => false
  end
end
