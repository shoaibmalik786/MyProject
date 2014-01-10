class CreateTradeyaMatchingResults < ActiveRecord::Migration
  def change
    create_table :tradeya_matching_results do |t|
      t.integer :user_id, :null => false
      t.string :match_result_q, :default => "", :null => false
      t.text :matched_log_data
      t.string :processed_ids, :default => "", :null => false
      t.integer :status, :default => 1, :null => false           # 1 PRESENT, 0 FINISH

      t.timestamps
    end
  end
end
