class ChangeFieldsDashboardQuestions < ActiveRecord::Migration
  def change
  	rename_column :dashboard_questions, :status, :question_status
  	rename_column :dashboard_questions, :type, :question_type
  end
end
