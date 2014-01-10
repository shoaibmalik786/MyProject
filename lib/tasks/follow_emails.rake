desc "After all users start following their social network friends, send the follow emails in batches at regular intervals."
namespace :marketing do
	task :send_follow_emails => :environment do
		puts Time.current
    puts "Rake Task Started...."
		followed_user_ids = Follow.where(:email_sent => false).pluck(:followed_id).uniq 
		if followed_user_ids.present?
			followed_users = User.find(followed_user_ids)
			followed_users.each do |u|
				pending_follow_emails = Follow.where(:followed_id => u.id,:email_sent => false).limit(1)
				pending_follow_emails.each do |follow|
					puts follow.follower_id.to_s + " - " + follow.followed_id.to_s
					# Send follow email
					UserMailer.user_followed(follow.follower_id,follow.followed_id).deliver
					follow.email_sent = true
					follow.save
				end
			end #loop
		else
			puts "No emails to send !"
		end
		puts "------------------------------------------------------"
    puts "Rake Task Ended..."
    puts Time.current
    puts "=========================================================================================================="
	end #task
end #namespace