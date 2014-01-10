class AddReviewTokenToTrade < ActiveRecord::Migration
  def change
    add_column :trades, :single_review_token, :string, :default => nil
  end
end
