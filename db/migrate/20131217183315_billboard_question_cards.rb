class BillboardQuestionCards < ActiveRecord::Migration
 def change
    create_table :dashboard_questions do |t|
      t.integer :type
      t.string :title
      t.string :description
      t.string :button_text
      t.string :action_item
      t.integer :status
      
      t.timestamps
    end
  end
end
