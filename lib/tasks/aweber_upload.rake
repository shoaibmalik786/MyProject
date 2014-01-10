# # This rake file authorize with aweber.com and upload user emails to Aweber.com.
# # They can be executed as follows:

# desc "Upload emails."
# namespace :aweber do
# # rake upload_emails
#   task :upload_emails => [:environment] do
#     aweber = AweberInfo.getAweberInfo
#     oauth = AWeber::OAuth.new(AWEBER_CONSUMER_KEY, AWEBER_CONSUMER_SECRET)
#     oauth.authorize_with_access(aweber.token, aweber.secret)

#     users = []
#     if aweber.last_upload.nil?
#       users = User.find_by_sql("SELECT email, created_at FROM users ORDER BY created_at DESC")
#     else
#       last_upload_d = aweber.last_upload.utc.strftime("%Y-%m-%d %H:%M:%S")
#       users = User.find_by_sql("SELECT email, created_at FROM users WHERE created_at > '" + last_upload_d + "' ORDER BY created_at DESC")
#     end

#     puts DateTime.now
#     puts "Records Found: " + users.count.to_s

#     if users.count > 0
#       aweber.last_upload = users[0].created_at
#       aweber.save

#       l = AWeber::Base.new(oauth).account.lists.find_by_name(AWEBER_LIST_NAME)

#       users.each do |u|
#         begin
#           r = l.subscribers.create :email => u.email
#           if r
#             puts "uploaded: " + u.email
#           else
#             puts "Unable to upload email: " + u.email
#           end
#         rescue StandardError => e
#           puts "Unable to upload email: " + u.email
#         end
#       end
#     end
#   end

# # rake authorize_url
#   task :authorize_aweber => [:environment] do
#     aweber = AweberInfo.getAweberInfo
#     oauth = AWeber::OAuth.new(AWEBER_CONSUMER_KEY, AWEBER_CONSUMER_SECRET)
#     puts oauth.request_token.authorize_url
#     puts "Go to URL outputed above, authorize your account!"
#     puts "Enter verification code below:"
#     verification_code = STDIN.gets.chomp

#     begin
#       r = oauth.authorize_with_verifier(verification_code)
#       aweber.token = r.token
#       aweber.secret = r.secret
#       aweber.save
#       puts "Token: " + r.token
#       puts "Secret: " + r.secret
#       puts "authorize and saved token and secret in DB."
#     rescue StandardError => e
#       puts e
#       puts "verification_code is not valid!"
#     end
#   end
# end