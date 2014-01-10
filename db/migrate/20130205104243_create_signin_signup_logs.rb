class CreateSigninSignupLogs < ActiveRecord::Migration
  def change
    create_table :signin_signup_logs do |t|
    	t.text :request_url
        t.text :request_referer
    	t.string :req_method
        t.string :remote_ip
    	t.string :current_user
    	t.integer :current_user_id
    	t.string :cur_authenticity_token
    	t.string :req_authenticity_token
    	t.string :req_email
    	t.string :session_id
        t.string :status
        t.string :desc
    	t.text :user_agent
    	t.text :params
        t.text :session

    	t.timestamps
    end
  end
end
