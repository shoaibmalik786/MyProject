class AddRatingToReview < ActiveRecord::Migration
  def change
  	add_column :reviews, :title, :string
  	add_column :reviews, :describe_rating, :integer
  	add_column :reviews, :communication_rating, :integer
  	add_column :reviews, :overall_rating, :integer
  end
end
