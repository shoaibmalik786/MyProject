class AddOnboardingtimestampToUser < ActiveRecord::Migration
  def change
  	add_column :users, :onboarding_at, :timestamp 
  end
end
