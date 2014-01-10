class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
    	
    	t.integer :reviewee_id #User undergoing review
    	t.integer :reviewer_id #User writing the review
    	t.text :review_text
    	t.integer :accepted_offer_id
    	t.boolean :request_remove_flag, :default => false

      t.timestamps
    end
  end
end
