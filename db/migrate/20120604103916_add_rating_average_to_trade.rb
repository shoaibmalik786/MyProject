class AddRatingAverageToTrade < ActiveRecord::Migration
  def change
    add_column :trades, :rating_average, :decimal, :default => 0, :precision => 6, :scale => 2
  end
end
