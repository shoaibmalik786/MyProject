# This rake file send email to offerers.
# They can be executed as follows:

desc "Tasks related to Guest User"
namespace :guest do
# rake Send email to offerers.
  task :guest_notifications => [:environment] do

    puts "Executed at - " + Time.now.to_s

    begin
      time_30 = (Time.zone.now - 30.days).to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
      time_29 = (Time.zone.now - 29.days).to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
      time_2 = (Time.zone.now - 2.days).to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
      time_1 = (Time.zone.now - 1.days).to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")

      mailed_users = []

      # Farewell users - 24 hours without confirmation
      farewell = User.find(:all, :conditions => "active = true AND is_guest_user = true AND confirmed_at IS NULL AND created_at <= '#{time_1}'")
      farewell.each do |user|
        user.guest_mail_sent_at = Time.zone.now
        user.guest_user_token = token = SecureRandom.urlsafe_base64(25) + user.id.to_s unless user.guest_user_token.present?
        user.is_active = false
        user.save
        user.lock_access!
        EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_GUEST_FAREWELL, user.id)
        mailed_users[mailed_users.count] = user
      end

      puts "Farewell users, 24 hours without confirmation, sent to - " + mailed_users.to_s
      mailed_users = []

      # Farewell users - 30 days have expired
      farewell = User.find(:all, :conditions => "active = true AND is_guest_user = true AND created_at <= '#{time_30}'")
      farewell.each do |user|
        user.guest_mail_sent_at = Time.zone.now
        user.guest_user_token = token = SecureRandom.urlsafe_base64(25) + user.id.to_s unless user.guest_user_token.present?
        user.is_active = false
        user.save
        user.lock_access!
        EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_GUEST_FAREWELL, user.id)
        mailed_users[mailed_users.count] = user
      end

      puts "Farewell users, 30 days have expired, sent to - " + mailed_users.to_s
      mailed_users = []
      
      # Final reminder - 29 days have expired
      final = User.find(:all, :conditions => "active = true AND is_guest_user = true AND created_at <= '#{time_29}'")
      final.each do |user|
        # send mail
        user.guest_mail_sent_at = Time.zone.now
        user.guest_user_token = token = SecureRandom.urlsafe_base64(25) + user.id.to_s unless user.guest_user_token.present?
        user.save

        EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_GUEST_FINAL_REMINDER, user.id)
        mailed_users[mailed_users.count] = user
      end

      puts "Final reminder, 29 days have expired, sent to - " + mailed_users.to_s
      mailed_users = []

      # Normal reminder - sent every 48 hours
      final = User.find(:all, :conditions => "active = true AND is_guest_user = true AND guest_mail_sent_at <= '#{time_2}'")
      final.each do |user|
        # send mail
        user.guest_mail_sent_at = Time.zone.now
        user.guest_user_token = token = SecureRandom.urlsafe_base64(25) + user.id.to_s unless user.guest_user_token.present?
        user.save
        EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_GUEST_UPGRADE_REMINDER, user.id)
        mailed_users[mailed_users.count] = user
      end

      puts "Normal reminder, every 48 hours, sent to - " + mailed_users.to_s
      mailed_users = []
    rescue StandardError => e 
      puts Time.now.to_s + " - Exception occured - " + e.message + "\n" + e.backtrace.to_s
      e = nil
    end

  end
end