class CreateInfoAndSettings < ActiveRecord::Migration
  def change
    create_table :info_and_settings do |t|
      t.integer :current_spotlight
      t.integer :exp_mail_sent_id, :default => 0

      t.boolean :sm_on_trd_live, :default => false, :null => false
      t.boolean :sm_on_o_made, :default => false, :null => false
      t.boolean :sm_on_ends_in_24_hour, :default => false, :null => false
      t.boolean :sm_on_rated_ur_i, :default => false, :null => false
      t.boolean :sm_on_o_on_ur_o, :default => false, :null => false
      t.boolean :sm_on_o_higher_than_ur, :default => false, :null => false

      t.timestamps
    end
  end
end
