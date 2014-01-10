class AddLinkedInColumnsToAuthentication < ActiveRecord::Migration
  def up
    add_column :authentications, :access_token, :string
    add_column :authentications, :access_secret, :string
  end

  def down
    remove_column :authentications, :access_token
    remove_column :authentications, :access_secret
  end
  
end
