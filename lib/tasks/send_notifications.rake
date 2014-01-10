# This rake file send email to offerers.
# They can be executed as follows:

desc "Send email to offerers."
namespace :notification do
  # rake Send imidiate notifications.
  task :send_imidiate => [:environment] do
    ntfcs = EventNotification.find(:all, :conditions => {:notification_type => NOTIFICATION_TYPE_IMIDIATE, :status => "NEW"}, :order => 'created_at ASC', :limit => 1000)
    ntfcs.each do |n|
      n.status = "IN_PROCESS"
      n.save
    end
    ntfcs.each do |n|
      begin
        EventNotification.send_notification_via_mail(n)
        n.status = n.status + "/" + "MAIL_SENT_IMIDIATE"
        n.sent = true
        n.save
      rescue StandardError => e
        puts e.message
        if e.message == "mail disabled"
          n.status = n.status + "/" + "MULTIPLE MAIL OR DISABLE BY ADMIN"
        else
          n.status = n.status + "/" + "FAILED"
        end
        n.save
      end

      if n.chk_user_setting and n.user.notify_via_mobile
        begin
          EventNotification.send_notification_via_sms(n)
          n.status = n.status + "/" + "SMS_SENT_IMIDIATE"
          n.sent = true
          n.save
        rescue
          n.status = n.status + "/" + "FAILED"
          n.save
        end
      end
    end
  end

  # rake Send imidiate notifications.
  task :send_imidiate_notification => [:environment] do
    ntfcs = EventNotification.find(:all, :conditions => {:notification_type => NOTIFICATION_TYPE_USER_SETTING, :status => "NEW"}, :order => 'created_at ASC', :limit => 1000)
    ntfcs.each do |n|
      n.status = "IN_PROCESS"
      n.save
    end
    ntfcs.each do |n|
      if not n.user.notify_via_email
        n.status = n.status + "/" + "EMAIL_OFF"
        n.save
      elsif n.user.notification_frequency == 1
        begin
          EventNotification.send_notification_via_mail(n)
          n.status = n.status + "/" + "MAIL_SENT_VIA_IMIDIATE_SETTING"
          n.sent = true
          n.save
        rescue StandardError => e
          puts e.message
          if e.message == "mail disabled"
            n.status = n.status + "/" + "MULTIPLE MAIL OR DISABLE BY ADMIN"
          else
            n.status = n.status + "/" + "FAILED"
          end
          n.save
        end
      elsif n.user.notification_frequency == 2
        n.status = "DAILY"
        n.save
      elsif n.user.notification_frequency == 3
        n.status = "WEEKLY"
        n.save
      end

      if not n.user.notify_via_mobile and n.user.notification_frequency == 1
        n.status = n.status + "/" + "SMS_OFF"
        n.save
      elsif n.user.notification_frequency == 1
        begin
          EventNotification.send_notification_via_sms(n)
          n.status = n.status + "/" + "SMS_SENT_VIA_IMIDIATE_SETTING"
          n.sent = true
          n.save
        rescue
          n.status = n.status + "/" + "FAILED"
          n.save
        end
      end
    end
  end

  # rake Send daily notifications.
  task :send_daily_notification => [:environment] do
    # ntfcs = EventNotification.find(:all, :conditions => {:notification_type => NOTIFICATION_TYPE_USER_SETTING, :status => "DAILY"}, :order => 'created_at ASC', :limit => 1000)
    users = User.find(:all, :conditions => {:notification_frequency => NOTIFICATION_FREQUENCY_DAILY, :notify_via_email => true})

    users.each do |u|
      EventNotification.notification_mail_daily_or_weekly(u,"DAILY")
    end

    users = User.find(:all, :conditions => {:active => 1})
    users.each do |u|
      # Send matching mails
      last_EventNotification = EventNotification.find(:last, :conditions => ["notification_no IN (#{NOTIFICATION_CATEGORY_MATCH},#{NOTIFICATION_PERSON_MATCH}) and user_id = #{u.id}"])
      if (last_EventNotification.nil? or (last_EventNotification.notification_no == NOTIFICATION_PERSON_MATCH))
        if not u.send_tradeya_match_mail then u.send_person_match_mail end
      elsif last_EventNotification.notification_no == NOTIFICATION_CATEGORY_MATCH
        if not u.send_person_match_mail then u.send_tradeya_match_mail end
      end
    end

    # ntfcs.each do |n|
    #   if not n.user.notify_via_email
    #     n.status = "EMAIL_OFF"
    #     n.save
    #   else
    #     begin
    #       EventNotification.send_notification_via_mail(n)
    #       n.status = "MAIL_SENT_VIA_DAILY_SETTING"
    #       n.sent = true
    #       n.save
    #     rescue
    #       n.status = "FAILED"
    #       n.save
    #     end
    #   end

    #   if not n.user.notify_via_mobile
    #     n.status = n.status + "/" + "SMS_OFF"
    #     n.save
    #   else
    #     begin
    #       EventNotification.send_notification_via_sms(n)
    #       n.status = n.status + "/" + "SMS_SENT_VIA_DAILY_SETTING"
    #       n.sent = true
    #       n.save
    #     rescue
    #       n.status = n.status + "/" + "FAILED"
    #       n.save
    #     end
    #   end
    # end
  end

  # rake Send weekly notifications.
  task :send_weekly_notification => [:environment] do
     users = User.find(:all, :conditions => {:notification_frequency => NOTIFICATION_FREQUENCY_WEEKLY, :notify_via_email => true})

    users.each do |u|
      EventNotification.notification_mail_daily_or_weekly(u,"WEEKLY")
    end
    # ntfcs = EventNotification.find(:all, :conditions => {:notification_type => NOTIFICATION_TYPE_USER_SETTING, :status => "WEEKLY"}, :order => 'created_at ASC', :limit => 1000)
    # ntfcs.each do |n|
    #   if not n.user.notify_via_email
    #     n.status = "EMAIL_OFF"
    #     n.save
    #   else
    #     begin
    #       EventNotification.send_notification_via_mail(n)
    #       n.status = "MAIL_SENT_VIA_WEEKLY_SETTING"
    #       n.sent = true
    #       n.save
    #     rescue
    #       n.status = "FAILED"
    #       n.save
    #     end
    #   end

    #   if not n.user.notify_via_mobile
    #     n.status = n.status + "/" + "SMS_OFF"
    #     n.save
    #   else
    #     begin
    #       EventNotification.send_notification_via_sms(n)
    #       n.status = n.status + "/" + "SMS_SENT_VIA_WEEKLY_SETTING"
    #       n.sent = true
    #       n.save
    #     rescue
    #       n.status = n.status + "/" + "FAILED"
    #       n.save
    #     end
    #   end
    # end
  end
end