class AddColsForStopMails < ActiveRecord::Migration
  def up
  	add_column :info_and_settings, :sm_on_c, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_c_pub_copy, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_c_all, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_t_postponed, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_t_resume, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_acc_deactivated, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_o_on_t_edited, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_o_on_t_deleted, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_o_accepted, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_t_completed, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_t_postponed_pub, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_t_reactivated, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_write_review, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_cat_match, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_person_match, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_contest_mail, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_g_upgrade_reminder, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_g_final_reminder, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_g_farewell, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_moving_on, :boolean, :default => false, :null => false

	remove_column :info_and_settings, :sm_on_o_submitted
	remove_column :info_and_settings, :sm_on_selected_tradeya
  end

  def down
  	remove_column :info_and_settings, :sm_on_c
  	remove_column :info_and_settings, :sm_on_c_pub_copy
  	remove_column :info_and_settings, :sm_on_c_all
  	remove_column :info_and_settings, :sm_on_t_postponed
  	remove_column :info_and_settings, :sm_on_t_resume
  	remove_column :info_and_settings, :sm_on_acc_deactivated
  	remove_column :info_and_settings, :sm_on_o_on_t_edited
  	remove_column :info_and_settings, :sm_on_o_on_t_deleted
  	remove_column :info_and_settings, :sm_on_o_accepted
  	remove_column :info_and_settings, :sm_on_t_completed
  	remove_column :info_and_settings, :sm_on_t_postponed_pub
  	remove_column :info_and_settings, :sm_on_t_reactivated
  	remove_column :info_and_settings, :sm_on_write_review
  	remove_column :info_and_settings, :sm_on_cat_match
  	remove_column :info_and_settings, :sm_on_person_match
  	remove_column :info_and_settings, :sm_on_contest_mail
  	remove_column :info_and_settings, :sm_on_g_upgrade_reminder
  	remove_column :info_and_settings, :sm_on_g_final_reminder
  	remove_column :info_and_settings, :sm_on_g_farewell
  	remove_column :info_and_settings, :sm_on_moving_on

  	add_column :info_and_settings, :sm_on_o_submitted, :boolean, :default => false, :null => false
  	add_column :info_and_settings, :sm_on_selected_tradeya, :boolean, :default => false, :null => false
  end
end
