class EventNotificationMailer < ActionMailer::Base
  include SendGrid

  def test_email(to = 'Shantanu <shan@addvalsolutions.com>', from = 'tradeya-dev@addvalsolutions.com', subject = 'nothing this is only test mail!')
    # headers['X-SMTPAPI'] = '{"category": "Test Category 2"}'
    sendgrid_category "Test Category"
    sendgrid_enable :ganalytics
    utm_hash = {                                
                :utm_campaign => 'promo', 
                :utm_source => 'welcome_email', 
                :utm_medium => 'email', 
                :utm_content => 'header_link',
                :utm_term => 'intro+text'
               }
    sendgrid_ganalytics_options(
                                utm_hash
                               )
    body = "this is the body ... link to #{user_url(237)}"
    mail(:to => to, :subject => subject, :from => from, :body => body)
    # mail(:to => to, :subject => subject, :from => from, :category => "Test Category")
  end

  def contact(n)
    @item = n.item
    @msg = n.msg
    @user = n.from
    @trade = n.trade
    headers['X-SMTPAPI'] = '{"category": "Publisher contacts offerer"}'
    mail(:to => @item.user.email, :subject => n.subject, :from => n.from.email, :content_type => "text/html")
  end
  # def contact(user, i, subject, m)
  #   @item = i
  #   @msg = m
  #   mail(:to => i.user.email, :subject => subject, :from => user.email, :content_type => "text/html")
  # end

  def contact_pub_copy(n)
    @offer = n.item
    @user = n.user
    @msg = n.msg
    @trade = n.trade
    headers['X-SMTPAPI'] = '{"category": "Publisher contacts offerer copy"}'
    mail(:to => n.user.email, :subject => "You sent a message!", :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => "text/html")
  end
  # def contact_pub_copy(u,ofr,msg)
  #   @offer = ofr
  #   @user = u
  #   @msg = msg
  #   mail(:to => u.email, :subject => "You sent a message!", :from => 'AdminRobot@TradeYa.com', :content_type => "text/html")
  # end

  # def spotlight_is_live(i)
  #   @item = i
  #   mail(:to => i.user.email, :subject => 'Your TradeYa is live', :from => 'Jared <jared@tradeya.com>', :content_type => "text/html")
  # end
  #
  def spotlight_is_expire(n)
    @item = n.item
    sub = @item.other_trades.count > 0 ? 'TradeYa expired: ' + @item.title : 'Your TradeYa has expired'
    headers['X-SMTPAPI'] = '{"category": "TradeYa expired"}'
    mail(:to => n.user.email, :subject => sub, :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => "text/html")
  end
  # def tradeya_is_expire(i)
  #   @item = i
  #   sub = @item.other_trades.count > 0 ? 'TradeYa expired: ' + @item.title : 'Your TradeYa has expired'
  #   mail(:to => i.user.email, :subject => sub, :from => 'AdminRobot@TradeYa.com', :content_type => "text/html")
  # end

  def offer_is_made(n)
    @trade = n.trade
    headers['X-SMTPAPI'] = '{"category": "TradeYa receives offer"}'
    mail(:to => n.user.email, :subject => 'Your TradeYa has an offer!', :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => "text/html")
  end
  # def offer_is_made(t)
  #   @trade = t
  #   mail(:to => t.item.user.email, :subject => 'You have an offer!', :from => 'AdminRobot@TradeYa.com', :content_type => "text/html")
  # end

  def offer_ends_in_24_hour(n)
    @item = n.item
    sub = @item.other_trades.count > 0 ? 'Ending in 24 hours: \'' + @item.title + '\'': 'Get more offers for your TradeYa!'
    headers['X-SMTPAPI'] = '{"category": "TradeYa ends in 24 hours"}'
    mail(:to => @item.user.email, :subject => sub, :from => 'Cassandra@TradeYa.com', :content_type => "text/html")
  end
  # def offer_ends_in_24_hour(i)
  #   @item = i
  #   sub = @item.other_trades.count > 0 ? 'Ending in 24 hours: ' + @item.title : 'Get more offers for your ' + @item.title
  #   mail(:to => i.user.email, :subject => sub, :from => 'Cassandra@TradeYa.com', :content_type => "text/html")
  # end

  def rated_your_item(n)
    @trade = n.trade
    headers['X-SMTPAPI'] = '{"category": "Item rated by publisher"}'
    mail(:to => @trade.offer.user.email, :subject => @trade.item.user.title + ' has rated your offer on TradeYa', :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end
  # def rated_your_item(t)
  #   @trade = t
  #   mail(:to => t.offer.user.email, :subject => t.item.user.title + ' has rated your offer on TradeYa', :from => 'Jared <jared@tradeya.com>', :content_type => "text/html")
  # end

  def offer_made_on_your_offer(n)
    @trade = n.trade
    headers['X-SMTPAPI'] = '{"category": "Offer made on your offer"}'
    mail(:to => @trade.offer.user.email, :subject => 'You have competition!', :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end
  # def offer_made_on_your_offer(t)
  #   @trade = t
  #   mail(:to => t.offer.user.email, :subject => 'You have competition!', :from => 'Jared <jared@tradeya.com>', :content_type => "text/html")
  # end

  def someone_offer_higher_than_yours(n)
    @trade = n.trade
    headers['X-SMTPAPI'] = '{"category": "Offer rated higher than yours"}'
    mail(:to => @trade.offer.user.email, :subject => @trade.item.user.first_name + ' has rated another offer higher than yours', :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end
  # def someone_offer_higher_than_yours(t)
  #   @trade = t
  #   mail(:to => t.offer.user.email, :subject => t.item.user.first_name + ' has rated another offer higher than yours', :from => 'Jared <jared@tradeya.com>', :content_type => "text/html")
  # end

  def spotlight_is_live(n)
    @item = n.item
    headers['X-SMTPAPI'] = '{"category": "TradeYa is live"}'
    mail(:to => @item.user.email, :subject => 'Your TradeYa is now live!', :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => "text/html")
  end
  # def tradeya_is_live(i)
  #   @item = i
  #   mail(:to => i.user.email, :subject => 'Your TradeYa is Live', :from => 'AdminRobot@TradeYa.com', :content_type => "text/html")
  # end


  def rate_offer(n)
    @trade = n.trade
    headers['X-SMTPAPI'] = '{"category": "Unrated offer on your TradeYa"}'
    mail(:to => @trade.item.user.email, :subject => 'You have an unrated offer on your TradeYa', :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end
  # def rate_offer(t)
  #   @trade = t
  #   mail(:to => t.item.user.email, :subject => 'You have an unrated offer on your TradeYa', :from => 'Jared <jared@tradeya.com>', :content_type => "text/html")
  # end

  # def tradeya_selected(i)
  #   @item = i
  #   mail(:to => i.user.email, :subject => "You're up! Your TradeYa is going live soon...", :from => 'Jared <jared@tradeya.com>', :content_type => "text/html")
  # end
  #

  def see_comment(n)
    @comment = n.comment
    @item = @comment.item
    @user = @comment.user
    headers['X-SMTPAPI'] = '{"category": "TradeYa gets comment or question"}'
    mail(:to => @item.user.email, :subject => 'Your TradeYa has a comment/question!', :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => "text/html")
  end
  # def see_comment(i, u,cmt)
  #   @item = i
  #   @user = u
  #   @comment = cmt
  #   mail(:to => i.user.email, :subject => 'Your TradeYa has a comment/question', :from => 'AdminRobot@TradeYa.com', :content_type => "text/html")
  # end

  def see_pub_comment(n)
    @comment = n.comment
    @item = @comment.item
    @user = n.user
    headers['X-SMTPAPI'] = '{"category": "Publisher comments on tradeya"}'
    mail(:to => @user.email, :subject => @item.user.first_name_in_caps + ' also commented on ' + @item.title, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end
  # def see_pub_comment(i, u)
  #   @item = i
  #   @user = u
  #   mail(:to => u.email, :subject => i.user.title + ' commented on ' + i.title, :from => 'Jared <jared@tradeya.com>', :content_type => "text/html")
  # end

  def contact_all(n)
    @item = n.item
    @msg = n.msg
    @current_user = n.from
    if n.data_by_key("copy2me")
      mail(:to => n.email_ids, :cc => n.from.email, :subject => n.subject, :from => n.from.email, :content_type => "text/html")
    else
      headers['X-SMTPAPI'] = '{"category": "Contact"}'
      mail(:to => n.email_ids, :subject => n.subject, :from => n.from.email, :content_type => "text/html")
    end
  end
  # def contact_all(user, i, subject, m, copy2me = false, u = nil,emails)
  #   @item = i
  #   @msg = m
  #   @current_user = user
  #   if copy2me
  #     mail(:to => emails, :cc => u.email, :subject => subject, :from => user.email, :content_type => "text/html")
  #   else
  #     mail(:to => emails, :subject => subject, :from => user.email, :content_type => "text/html")
  #   end
  # end

  def tradeya_postponed(n)
    @tradeya = n.trade.item
    @offer = n.trade.offer
    headers['X-SMTPAPI'] = '{"category": "TradeYa postponed offerer copy"}'
    mail(:to => @offer.user.email, :subject => 'TradeYa has been Postponed', :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end
  # def tradeya_postponed(itm,ofr)
  #   @tradeya = itm
  #   @offer = ofr
  #   mail(:to => ofr.user.email, :subject => 'TradeYa has been Postponed', :from => 'Jared <jared@tradeya.com>', :content_type => "text/html")
  # end

  def tradeya_resumed(n)
    @tradeya = n.trade.item
    @offer = n.trade.offer
    headers['X-SMTPAPI'] = '{"category": "TradeYa resumed offerer copy"}'
    mail(:to => @offer.user.email, :subject => 'TradeYa has been Resumed', :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end
  # def tradeya_resumed(itm,ofr)
  #   @tradeya = itm
  #   @offer = ofr
  #   mail(:to => ofr.user.email, :subject => 'TradeYa has been Resumed', :from => 'Jared <jared@tradeya.com>', :content_type => "text/html")
  # end

  def your_account_deactivated(n)
    @user = n.user
    headers['X-SMTPAPI'] = '{"category": "Account deactivated"}'
    mail(:to => @user.email, :subject => 'Sorry to see you go! [Account Deactivated]', :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end
  # def your_account_deactivated(u)
  #   @user = u
  #   mail(:to => u.email, :subject => 'Sorry to see you go! ' + u.first_name, :from => 'Jared <jared@tradeya.com>', :content_type => "text/html")
  # end

  def offer_on_tradeya_edited(n)
    @item = n.trade.item
    @offer = n.trade.offer
    headers['X-SMTPAPI'] = '{"category": "Offer on TradeYa updated"}'
    mail(:to => @item.user.email, :subject => 'An offer on your TradeYa has been updated',:from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => "text/html")
  end
  # def offer_on_tradeya_edited(i,o)
  #   @item = i
  #   @offer = o
  #   mail(:to => i.user.email, :subject => 'An offer on your TradeYa has been updated',:from => 'AdminRobot@TradeYa.com', :content_type => "text/html")
  # end

  def offer_on_tradeya_deleted(n)
    @item = n.trade.item
    @offer = n.trade.offer
    @is_currentOffer = n.trade.accepted_offer.nil?
    sub = (@is_currentOffer ? 'An offer has been deleted for your TradeYa' : 'An offer on your TradeYa has been deleted')
    headers['X-SMTPAPI'] = '{"category": "Offer on TradeYa deleted"}'
    mail(:to => @item.user.email, :subject => sub,:from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => "text/html")
  end
  # def offer_on_tradeya_deleted(i,o)
  #   @item = i
  #   @offer = o
  #   sub = @item.other_trades.count > 0 ? 'An offer has been deleted for ' + @item.title : 'An offer on your TradeYa has been deleted'
  #   mail(:to => i.user.email, :subject => sub,:from => 'AdminRobot@TradeYa.com', :content_type => "text/html")
  # end

  def offer_accepted(n)
    @item = n.trade.item
    @offer = n.trade.offer
    @msg = n.msg
    headers['X-SMTPAPI'] = '{"category": "Offer is accepted"}'
    if n.data_by_key("copy2me")
      mail(:to => @offer.user.email, :cc => @item.user.email, :subject => 'It\'s a Trade! Your offer has been accepted.',:from => 'AdminRobot@TradeYa.com', :content_type => "text/html")
    else
      mail(:to => @offer.user.email, :subject => 'It\'s a Trade! Your offer has been accepted',:from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => "text/html")
    end
  end
  # def offer_accepted(i,o,msg)
  #   @item = i
  #   @offer = o
  #   @msg = msg
  #   mail(:to => o.user.email, :subject => 'Your offer has been accepted!',:from => 'AdminRobot@TradeYa.com', :content_type => "text/html")
  # end

  def tradeya_completed(n)
    @item = n.item
    headers['X-SMTPAPI'] = '{"category": "TradeYa complete"}'
    mail(:to => @item.user.email, :subject => 'Success! Your TradeYa is complete!', :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => 'text/html')
  end
  # def tradeya_completed(i)
  #   @item = i
  #   mail(:to => i.user.email, :subject => 'Success! Your TradeYa is complete!', :from => 'AdminRobot@TradeYa.com', :content_type => 'text/html')
  # end

  def tradeya_postponed_pub(n)
    @item = n.item
    headers['X-SMTPAPI'] = '{"category": "TradeYa Postponed publisher"}'
    mail(:to => @item.user.email, :subject => 'Your TradeYa has been postponed', :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => 'text/html')
  end
  # def tradeya_postponed_pub(i)
  #   @item = i
  #   mail(:to => i.user.email, :subject => 'You\'ve postponed your TradeYa', :from => 'AdminRobot@TradeYa.com', :content_type => 'text/html')
  # end

  def tradeya_reactivated(n)
    @item = n.item
    headers['X-SMTPAPI'] = '{"category": "TradeYa resubmitted publisher"}'
    mail(:to => @item.user.email, :subject => 'Your TradeYa has been resubmitted!', :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => 'text/html')
  end
  # def tradeya_reactivated(i)
  #   @item = i
  #   mail(:to => i.user.email, :subject => 'Your TradeYa has been reactivated', :from => 'AdminRobot@TradeYa.com', :content_type => 'text/html')
  # end

  def write_review(n)
    @pub = n.trade.item.user
    @user = n.trade.offer.user
    @token = n.data_by_key("token")
    headers['X-SMTPAPI'] = '{"category": "Write a review"}'
    mail(:to => @user.email, :subject => 'Leave ' + @pub.title + ' a review', :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => 'text/html')
  end
  # def write_review(to,pub,token)
  #   @pub = pub
  #   @token = token
  #   mail(:to => to, :subject => 'Leave ' + pub.title + ' a review', :from => 'AdminRobot@TradeYa.com', :content_type => 'text/html')
  # end

  def daily_or_weekly_notification(user,freq, nt, no)
    @nt = nt
    @no = no

    # @tradeya_count = user.get_user_total_tradeya_count
    # @offer_count = user.get_user_total_offer_count
    @user = user
    @freq = freq.capitalize
    headers['X-SMTPAPI'] = '{"category": "Your tradeya digest"}'
    mail(:to => user.email, :subject => 'Your TradeYa ' + @freq + ' Digest', :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => 'text/html')
  end

  def category_match(n)
    @user = n.user
    @item = n.item
    @token = n.token
    @matched_interests = @user.matched_interests(@item.user)
    @user_tradeya_count = @item.user.get_user_live_tradeya_count #Item.get_user_tradeyas_count(@item.user.id)
    headers['X-SMTPAPI'] = '{"category": "Match found"}'
    mail(:to => @user.email, :subject => @user.first_name_in_caps + ', we found you a match!', :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => 'text/html')
  end

  def person_match(n)
    @user = n.user
    @item = n.item
    @token = n.token
    @match_user = @item.user
    @matched_interests = n.matched_interests
    @user_tradeya_count = @item.user.get_user_live_tradeya_count #Item.get_user_tradeyas_count(@item.user.id)
    headers['X-SMTPAPI'] = '{"category": "Person meet"}'
    mail(:to => @user.email, :subject => @user.first_name_in_caps + ', meet ' + @match_user.first_name_in_caps, :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => 'text/html')
  end

  def self.send_contest_email(n)
    @cd = ContestData.find(n.data_by_key('contest_data_id'))
    if @cd.emails.present?
      @cd.emails.split(',').each do |recipient|
        contest_email(recipient).deliver
      end
    end
  end

  def contest_email(email)
    if not email.index('<').nil?
      @first_name = email.split('<')[0].strip.split(' ')[0].strip.capitalize
    else
      @first_name = email.split('@')[0]
    end
    mail(:to => email, :subject => 'Spread the good news!', :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => 'text/html')
  end

  def self.send_moving_on_mail(n)
    if n.email_ids.present?
      n.email_ids.split(',').each do |recipient|
        moving_on(recipient.strip, n.data_by_key('from').strip).deliver
      end
    end
    if n.data_by_key('send2all')
      User.all.each do |u|
        moving_on(u.email.strip, n.data_by_key('from').strip).deliver
      end
    end
  end

  def moving_on(email, from)
    mail(:to => email, :subject => "We're Moving On (Announcing The Next Chapter of TradeYa)", :from => (from.present? ? from : "TradeYa <AdminRobot@TradeYa.com>"), :content_type => 'text/html')
  end

  def guest_upgrade_reminder(n)
    @user = n.user
    mail(:to => @user.email, :subject =>  'Upgrade Your TradeYa Guest Account', :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => 'text/html')
  end

  def guest_final_reminder(n)
    @user = n.user
    mail(:to => @user.email, :subject =>  'Upgrade Your TradeYa Guest Account', :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => 'text/html')
  end

  def guest_farewell(n)
    @user = n.user
    mail(:to => @user.email, :subject =>  'Upgrade Your TradeYa Guest Account', :from => 'TradeYa <AdminRobot@TradeYa.com>', :content_type => 'text/html')
  end

  def multiple_mails(r, n)
    @details = r
    @n = n
    to = ["mukesh.singh@addvalsolutions.com", "addval.mahim@gmail.com"]
    mail(:to => to, :subject =>  'Alert: System sending multiple emails to users.', :from => 'Addval Development <dev@addvalsolutions.com>', :content_type => 'text/html')
  end

  def mail_for_item_info(n)
    @item = n.item
    @recipient = n.user
    @sender = n.from
    mail(to: @recipient.email, subject: 'Request for item information', :from => @sender.email)
  end

end
