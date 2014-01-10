class EventNotification < ActiveRecord::Base
  belongs_to :user

  scope :CONTACT, :conditions => [ "notification_no = 1" ]
  scope :CONTACT_PUB_COPY, :conditions => [ "notification_no = 2" ]
  scope :TRADEYA_EXPIRE, :conditions => [ "notification_no = 3" ]
  scope :OFFER_MADE, :conditions => [ "notification_no = 4" ]
  scope :OFFER_ENDS_IN_24_HOUR, :conditions => [ "notification_no = 5" ]
  scope :RATED_YOUR_ITEM, :conditions => [ "notification_no = 6" ]
  scope :OFFER_MADE_ON_YOUR_OFFER, :conditions => [ "notification_no = 7" ]
  scope :SOMEONE_OFFER_HIGHER_THAN_YOURS, :conditions => [ "notification_no = 8" ]
  scope :TRADEYA_IS_LIVE, :conditions => [ "notification_no = 9" ]
  scope :RATE_OFFER, :conditions => [ "notification_no = 10" ]
  scope :SEE_COMMENT, :conditions => [ "notification_no = 11" ]
  scope :SEE_PUB_COMMENT, :conditions => [ "notification_no = 12" ]
  scope :CONTACT_ALL, :conditions => [ "notification_no = 13" ]
  scope :TRADEYA_POSTPONED, :conditions => [ "notification_no = 14" ]
  scope :TRADEYA_RESUMED, :conditions => [ "notification_no = 15" ]
  scope :YOUR_ACCOUNT_DEACTIVATED, :conditions => [ "notification_no = 16" ]
  scope :OFFER_ON_TRADEYA_EDITED, :conditions => [ "notification_no = 17" ]
  scope :OFFER_ON_TRADEYA_DELETED, :conditions => [ "notification_no = 18" ]
  scope :OFFER_ACCEPTED, :conditions => [ "notification_no = 19" ]
  scope :TRADEYA_COMPLETED, :conditions => [ "notification_no = 20" ]
  scope :TRADEYA_POSTPONED_PUB, :conditions => [ "notification_no = 21" ]
  scope :TRADEYA_REACTIVATED, :conditions => [ "notification_no = 22" ]
  scope :WRITE_REVIEW, :conditions => [ "notification_no = 23" ]
  scope :CATEGORY_MATCH, :conditions => [ "notification_no = 24" ]
  scope :PERSON_MATCH, :conditions => [ "notification_no = 25" ]
  scope :CONTEST_EMAIL, :conditions => [ "notification_no = 26" ]
  scope :MOVING_ON, :conditions => [ "notification_no = 30" ]


  @i = nil
  @c = nil
  @t = nil
  @j = nil
  @f = nil
  @p

  def self.add_2_notification_q(notification_type, notification_no, user_id, notification_data = {})
    notification = EventNotification.new
    notification.notification_type = notification_type
    notification.notification_no = notification_no
    notification.user_id = user_id
    notification.data = notification_data.to_json
    notification.save
  end

  def item
    if @j.nil? then @j = JSON.parse(self.data) end

    if @i.nil? and not @j["item_id"].nil?
      @i = Item.find(@j["item_id"])
    end
    return @i
  end

  def person
    if @j.nil? then @j = JSON.parse(self.data) end

    if @p.nil? and not @j["person_id"].nil?
      @p = User.find(@j["person_id"])
    end
    return @p
  end

  def matched_interests
    if @j.nil? then @j = JSON.parse(self.data) end

    if @mis.nil? and not @j["matched_interests"].nil?
      ids = JSON.parse(@j["matched_interests"]).join(',')
      @mis = Category.find(:all, :conditions => ["id IN(#{ids})"])
    end
    return @mis
  end

  def comment
    if @j.nil? then @j = JSON.parse(self.data) end

    if @c.nil? and not @j["comment_id"].nil?
      @c = Comment.find(@j["comment_id"])
    end
    return @c
  end

  def chk_user_setting
    if @j.nil? then @j = JSON.parse(self.data) end

    return (@j["chk_user_setting"] == true)
  end

  def trade
    if @j.nil? then @j = JSON.parse(self.data) end

    if @t.nil? and not @j["trade_id"].nil?
      @t = Trade.find(@j["trade_id"])
    end
    return @t
  end

  def token
    if @j.nil? then @j = JSON.parse(self.data) end

    return @j["vote_token"]
  end

  def subject
    if @j.nil? then @j = JSON.parse(self.data) end

    return @j["subject"]
  end

  def msg
    if @j.nil? then @j = JSON.parse(self.data) end

    return @j["msg"]
  end

  def email_ids
    if @j.nil? then @j = JSON.parse(self.data) end

    return @j["email_ids"]
  end

  def from
    if @j.nil? then @j = JSON.parse(self.data) end

    if @f.nil? and not @j["user_id"].nil?
      @f = User.find(@j["user_id"])
    end

    return @f
  end

  def data_by_key(key)
    if @j.nil? then @j = JSON.parse(self.data) end

    return @j[key]
  end

  def self.send_notification_via_mail(n)
    f = Time.zone.parse(Time.zone.now.to_date.to_s).strftime("%Y-%m-%d %H:%M:%S")
    r = ActiveRecord::Base.connection.execute("select u.id as user_id, email, data, count(*) as count from event_notifications as n, users as u where u.id = n.user_id and n.created_at > '#{f}' and notification_no = #{n.notification_no} group by user_id, email, data having count > 1 order by count desc")
    case n.notification_no
      when NOTIFICATION_CONTACT
        if InfoAndSetting.sm_on_c
          EventNotificationMailer.contact(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_c(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_CONTACT_PUB_COPY
        if InfoAndSetting.sm_on_c_pub_copy
          EventNotificationMailer.contact_pub_copy(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_c_pub_copy(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_TRADEYA_EXPIRE
        if InfoAndSetting.sm_on_expired_tradeya
          EventNotificationMailer.spotlight_is_expire(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_expired_tradeya(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_OFFER_MADE
        if InfoAndSetting.sm_on_o_made
          EventNotificationMailer.offer_is_made(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_o_made(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_OFFER_ENDS_IN_24_HOUR
        if InfoAndSetting.sm_on_ends_in_24_hour
          EventNotificationMailer.offer_ends_in_24_hour(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_ends_in_24_hour(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_RATED_YOUR_ITEM
        if InfoAndSetting.sm_on_rated_ur_i
          EventNotificationMailer.rated_your_item(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_rated_ur_i(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_OFFER_MADE_ON_YOUR_OFFER
        if InfoAndSetting.sm_on_o_on_ur_o
          EventNotificationMailer.offer_made_on_your_offer(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_o_on_ur_o(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_SOMEONE_OFFER_HIGHER_THAN_YOURS
        if InfoAndSetting.sm_on_o_higher_than_ur
          EventNotificationMailer.someone_offer_higher_than_yours(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_o_higher_than_ur(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_TRADEYA_IS_LIVE
        if InfoAndSetting.sm_on_trd_live
          EventNotificationMailer.spotlight_is_live(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_trd_live(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_RATE_OFFER
        if InfoAndSetting.sm_on_24h_offer_not_rated
          EventNotificationMailer.rate_offer(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_24h_offer_not_rated(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_SEE_COMMENT
        if InfoAndSetting.sm_on_comment_by_other
          EventNotificationMailer.see_comment(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_comment_by_other(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_SEE_PUB_COMMENT
        if InfoAndSetting.sm_on_comment_by_pub
          EventNotificationMailer.see_pub_comment(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_comment_by_pub(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_CONTACT_ALL
        if InfoAndSetting.sm_on_c_all
          EventNotificationMailer.contact_all(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_c_all(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_TRADEYA_POSTPONED
        if InfoAndSetting.sm_on_t_postponed
          EventNotificationMailer.tradeya_postponed(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_t_postponed(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_TRADEYA_RESUMED
        if InfoAndSetting.sm_on_t_resume
          EventNotificationMailer.tradeya_resumed(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_t_resume(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_YOUR_ACCOUNT_DEACTIVATED
        if InfoAndSetting.sm_on_acc_deactivated
          EventNotificationMailer.your_account_deactivated(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_acc_deactivated(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_OFFER_ON_TRADEYA_EDITED
        if InfoAndSetting.sm_on_o_on_t_edited
          EventNotificationMailer.offer_on_tradeya_edited(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_o_on_t_edited(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_OFFER_ON_TRADEYA_DELETED
        if InfoAndSetting.sm_on_o_on_t_deleted
          EventNotificationMailer.offer_on_tradeya_deleted(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_o_on_t_deleted(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_OFFER_ACCEPTED
        if InfoAndSetting.sm_on_o_accepted
          EventNotificationMailer.offer_accepted(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_o_accepted(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_TRADEYA_COMPLETED
        if InfoAndSetting.sm_on_t_completed
          EventNotificationMailer.tradeya_completed(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_t_completed(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_TRADEYA_POSTPONED_PUB
        if InfoAndSetting.sm_on_t_postponed_pub
          EventNotificationMailer.tradeya_postponed_pub(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_t_postponed_pub(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_TRADEYA_REACTIVATED
        if InfoAndSetting.sm_on_t_reactivated
          EventNotificationMailer.tradeya_reactivated(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_t_reactivated(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_WRITE_REVIEW
        if InfoAndSetting.sm_on_write_review
          EventNotificationMailer.write_review(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_write_review(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_CATEGORY_MATCH
        if InfoAndSetting.sm_on_cat_match
          EventNotificationMailer.category_match(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_cat_match(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_PERSON_MATCH
        if InfoAndSetting.sm_on_person_match
          EventNotificationMailer.person_match(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_person_match(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_CONTEST_EMAIL
        if InfoAndSetting.sm_on_contest_mail
          EventNotificationMailer.send_contest_email(n)
          if r.count > 0 then InfoAndSetting.sm_on_contest_mail(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_GUEST_UPGRADE_REMINDER
        if InfoAndSetting.sm_on_g_upgrade_reminder
          EventNotificationMailer.guest_upgrade_reminder(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_g_upgrade_reminder(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_GUEST_FINAL_REMINDER
        if InfoAndSetting.sm_on_g_final_reminder
          EventNotificationMailer.guest_final_reminder(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_g_final_reminder(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_GUEST_FAREWELL
        if InfoAndSetting.sm_on_g_farewell
          EventNotificationMailer.guest_farewell(n).deliver
          if r.count > 0 then InfoAndSetting.sm_on_g_farewell(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_MOVING_ON
        if InfoAndSetting.sm_on_moving_on
          EventNotificationMailer.send_moving_on_mail(n)
          if r.count > 0 then InfoAndSetting.sm_on_moving_on(false) end
        else
          raise "mail disabled"
        end
      when NOTIFICATION_REQUEST_INFO
          EventNotificationMailer.mail_for_item_info(n).deliver        
    end
    if r.count > 0 then EventNotificationMailer.multiple_mails(r, n.notification_no).deliver end
  end

  def self.send_notification_via_sms(n)
    case n.notification_no
      when NOTIFICATION_CONTACT;
        # send_sms_notification(n.user, n.from.title + " contacted you with the Message - " + n.msg)
      when NOTIFICATION_CONTACT_PUB_COPY;
        # send_sms_notification(n.user, "You sent a message to " + n.item.user.title + ". Message - " + n.msg)
      when NOTIFICATION_TRADEYA_EXPIRE;
        send_sms_notification(n.user, "TradeYa expired.")
      when NOTIFICATION_OFFER_MADE;
        # send_sms_notification(n.user, "You received an offer on TradeYa " + n.trade.item.title + ".")
        send_sms_notification(n.user, "Offer received on tradeya.")
      when NOTIFICATION_OFFER_ENDS_IN_24_HOUR;
        # send_sms_notification(n.user, "Your TradeYa " + n.item.title + " is expiring in 24 hours.")
        send_sms_notification(n.user, "Trade has 24 hours remaining.")
      when NOTIFICATION_RATED_YOUR_ITEM;
        send_sms_notification(n.user, "Offer has been rated.")
      when NOTIFICATION_OFFER_MADE_ON_YOUR_OFFER;
        send_sms_notification(n.user, "Someone else made an offer.")
      when NOTIFICATION_SOMEONE_OFFER_HIGHER_THAN_YOURS;
        send_sms_notification(n.user, "Offer on rated higher than yours.")
      when NOTIFICATION_TRADEYA_IS_LIVE;
        send_sms_notification(n.user, "Trade is live.")
      when NOTIFICATION_RATE_OFFER;
        send_sms_notification(n.user, "Unrated offers awaiting.")
      when NOTIFICATION_SEE_COMMENT;
        send_sms_notification(n.user, "TradeYa received new comment/question.")
      when NOTIFICATION_SEE_PUB_COMMENT;
        send_sms_notification(n.user, "TradeYa received comment from Publisher.")
      when NOTIFICATION_CONTACT_ALL;
        # not handled yet
      when NOTIFICATION_TRADEYA_POSTPONED;
        send_sms_notification(n.user, "TradeYa postponed.")
      when NOTIFICATION_TRADEYA_RESUMED;
        send_sms_notification(n.user, "TradeYa has resumed.") 
      when NOTIFICATION_YOUR_ACCOUNT_DEACTIVATED;
        send_sms_notification(n.user,"Sorry to see you Go! Your TradeYa account is now de-activated.")
      when NOTIFICATION_OFFER_ON_TRADEYA_EDITED;
        send_sms_notification(n.user, "Offer on TradeYa was edited.")
      when NOTIFICATION_OFFER_ON_TRADEYA_DELETED;
        send_sms_notification(n.user, "Offer on TradeYa was deleted.")
      when NOTIFICATION_OFFER_ACCEPTED;
        send_sms_notification(n.user, "Offer accepted.")
      when NOTIFICATION_TRADEYA_COMPLETED;
        send_sms_notification(n.user, "TradeYa is complete.")
      when NOTIFICATION_TRADEYA_POSTPONED_PUB;
        send_sms_notification(n.user, "TradeYa postponed.")
      when NOTIFICATION_TRADEYA_REACTIVATED;
        send_sms_notification(n.user, "TradeYa is re-activated.")
      when NOTIFICATION_WRITE_REVIEW;
        send_sms_notification(n.user, "You can now leave a review for trade.")
    end
  end

# get notification type - tradeya or offer or user's account
  def n_type
    case notification_no
      when NOTIFICATION_TRADEYA_EXPIRE, NOTIFICATION_OFFER_MADE, 
        NOTIFICATION_OFFER_ENDS_IN_24_HOUR, NOTIFICATION_TRADEYA_IS_LIVE, NOTIFICATION_RATE_OFFER,
        NOTIFICATION_SEE_COMMENT, NOTIFICATION_OFFER_ON_TRADEYA_EDITED, NOTIFICATION_OFFER_ON_TRADEYA_DELETED,
        NOTIFICATION_TRADEYA_COMPLETED, NOTIFICATION_TRADEYA_POSTPONED_PUB, NOTIFICATION_TRADEYA_REACTIVATED; 
        return ALERT_TYPE_TRADEYA
      when NOTIFICATION_RATED_YOUR_ITEM, NOTIFICATION_OFFER_MADE_ON_YOUR_OFFER, NOTIFICATION_SOMEONE_OFFER_HIGHER_THAN_YOURS,
        NOTIFICATION_SEE_PUB_COMMENT, NOTIFICATION_OFFER_ACCEPTED, NOTIFICATION_TRADEYA_RESUMED, NOTIFICATION_TRADEYA_POSTPONED;
         return ALERT_TYPE_OFFER
      when NOTIFICATION_CONTACT, NOTIFICATION_CONTACT_PUB_COPY, NOTIFICATION_CONTACT_ALL, NOTIFICATION_YOUR_ACCOUNT_DEACTIVATED, 
        NOTIFICATION_WRITE_REVIEW; return ALERT_TYPE_OTHER
    end
  end

  def self.send_sms_notification(user,msg)
    @client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
    user.phone_numbers.each do |ph|
       @message = @client.account.sms.messages.create(
        :From => YOUR_CALLER_ID,
        :To => ph.phone_number,
        :Body => msg
      )
      puts @message
    end
  end

  def self.notification_mail_daily_or_weekly(user,freq)

    notifications = EventNotification.find(:all, :conditions => {:notification_type => NOTIFICATION_TYPE_USER_SETTING, :status => freq, :user_id => user.id}, :order => 'created_at ASC', :limit => 1000)

    nt = Hash.new # Notifications related to user's TradeYas
    no = Hash.new # Notifications related to user's Offers

    notifications.each do |n|

      # TradeYa Notifications
      if n.n_type == ALERT_TYPE_TRADEYA
        # get item on which notification has occurred
        item = nil
        if n.item then item = n.item
        elsif n.trade then item = n.trade.item
        elsif n.comment then item = n.comment.item
        end
         
        begin
          # check if another notification related to same item already exists
          if !nt.has_key?(item.id)
            nt[item.id] = Hash.new
            nt[item.id]["msg"] = Array.new
            nt[item.id]["item"] = item
          end
          EventNotification.add_notification_message(n,nt[item.id])
          update_status(n, "MAIL_SENT_VIA_"+freq+"_SETTING", true)
        rescue
            update_status(n, "FAILED", false)
        end
      # Offer Notifications
      elsif n.n_type == ALERT_TYPE_OFFER
        begin
          # check if another notification related to same trade already exists
          if !no.has_key?(n.trade.id)
            no[n.trade.id] = Hash.new
            no[n.trade.id]["msg"] = Array.new
            no[n.trade.id]["trade"] = n.trade
          end
          EventNotification.add_notification_message(n,no[n.trade.id])
          update_status(n, "MAIL_SENT_VIA_"+freq+"_SETTING", true)
        rescue
          update_status(n, "FAILED", false)
        end
      # Immediate Notifications
      elsif n.n_type == ALERT_TYPE_OTHER
  
      end
    end

    # Send mail if notifications exist
    EventNotificationMailer.daily_or_weekly_notification(user, freq, nt, no).deliver if (nt.size > 0 or no.size > 0)
  end

  # Converts notification into corresponding message
  def self.add_notification_message(n,message_hash)
    case n.notification_no
      when NOTIFICATION_CONTACT;
        
      when NOTIFICATION_CONTACT_PUB_COPY;
       
      when NOTIFICATION_OFFER_MADE;
        loc,count = location_and_count_message(message_hash, NOTIFICATION_OFFER_MADE)
        message_hash["msg"][loc] = "<li> " + count.to_s + " offer" + ((count > 1)? "s" : "") + " made </li>"
      when NOTIFICATION_OFFER_ENDS_IN_24_HOUR;
        message_hash["msg"].push("<li> ends in 24 hours</li>")
      when NOTIFICATION_RATED_YOUR_ITEM;
        loc,count = location_and_count_message(message_hash, NOTIFICATION_RATED_YOUR_ITEM)
        message_hash["msg"][loc] = "<li> rated " + count.to_s + " time" + ((count > 1)? "s" : "") + " </li>"
      when NOTIFICATION_OFFER_MADE_ON_YOUR_OFFER;
        loc,count = location_and_count_message(message_hash, NOTIFICATION_OFFER_MADE_ON_YOUR_OFFER)
        message_hash["msg"][loc] = "<li> " + count.to_s + " offer" + ((count>1) ? "s" : "") + " received after yours </li>"
      when NOTIFICATION_SOMEONE_OFFER_HIGHER_THAN_YOURS;
        loc,count = location_and_count_message(message_hash, NOTIFICATION_SOMEONE_OFFER_HIGHER_THAN_YOURS)
        message_hash["msg"][loc] = "<li> " + count.to_s + " offer" + ((count>1)? "s" : "") + " rated higher than yours </li>"
      when NOTIFICATION_TRADEYA_IS_LIVE;
        message_hash["msg"].push("<li> is live</li>")
      when NOTIFICATION_RATE_OFFER;
        loc, count = location_and_count_message(message_hash, NOTIFICATION_RATE_OFFER)
        message_hash["msg"][loc] = "<li> " + count.to_s + " unrated offer" + ((count>1)? "s" : "") + " </li>" 
      when NOTIFICATION_SEE_COMMENT;
        loc,count = location_and_count_message(message_hash, NOTIFICATION_SEE_COMMENT)
        message_hash["msg"][loc] = "<li> " + count.to_s + " new comment" + ((count>1)? "s" : "") + " </li>"
      when NOTIFICATION_SEE_PUB_COMMENT;
        loc,count = location_and_count_message(message_hash, NOTIFICATION_SEE_PUB_COMMENT)
        message_hash["msg"][loc] = "<li> " + count.to_s + " new comment" + ((count>1)? "s" : "") + " from Publisher </li>"
      when NOTIFICATION_CONTACT_ALL;

      when NOTIFICATION_TRADEYA_POSTPONED;
        message_hash["msg"].push("<li> turned inactive as the TradeYa was postponed </li>")
      when NOTIFICATION_TRADEYA_RESUMED;
        message_hash["msg"].push("<li> is ACTIVE now as the TradeYa has resumed </li>")
      when NOTIFICATION_YOUR_ACCOUNT_DEACTIVATED;

      when NOTIFICATION_OFFER_ON_TRADEYA_EDITED;
        loc,count = location_and_count_message(message_hash, NOTIFICATION_OFFER_ON_TRADEYA_EDITED)
        message_hash["msg"][loc] = "<li> " + count.to_s + " offer" + ((count>1)? "s" : "") + " edited </li>"
      when NOTIFICATION_OFFER_ON_TRADEYA_DELETED;
        loc,count = location_and_count_message(message_hash, NOTIFICATION_OFFER_ON_TRADEYA_DELETED)
        message_hash["msg"][loc] = " <li> " + count.to_s + " offer" + ((count>1) ? "s" : "") + " deleted </li>"
      when NOTIFICATION_OFFER_ACCEPTED;
        message_hash["msg"].push("<li> has been accepted!</li>")
      when NOTIFICATION_TRADEYA_COMPLETED;
        message_hash["msg"].push("<li> is COMPLETE !!!</li>")
      when NOTIFICATION_TRADEYA_POSTPONED_PUB;
        message_hash["msg"].push("<li> has been postponed</li>")
      when NOTIFICATION_TRADEYA_REACTIVATED;
        message_hash["msg"].push("<li> has been re-activated</li>")
      when NOTIFICATION_WRITE_REVIEW;
        
    end
  end

  def self.location_and_count_message(message_hash,key)
    loc = 0
    count = 0
    if !message_hash.has_key?(key)
      message_hash.store(key,"")
      loc = message_hash["msg"].size
      count = 1
    else
      arr = message_hash[key].split('/')
      loc = arr[0].to_i
      count = arr[1].to_i + 1
    end
    message_hash[key] = loc.to_s + '/' + count.to_s 
    return loc,count
  end

  def self.update_status(notification, status, sent)
    notification.status = status
    notification.sent = sent
    notification.save
  end

end
