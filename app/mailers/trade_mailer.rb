class TradeMailer < ActionMailer::Base
  include Resque::Mailer
  include SendGrid
  sendgrid_enable   :ganalytics

  default from: "jared@tradeya.com"

  def offer_made_offerer(item1,offerer,item2,owner)
    sendgrid_category "Submit Item Offer"
    @subject = "Success! You've submitted an offer!".html_safe
    @item1 = Item.find_by_id(item1)
    @offerer = User.find_by_id(offerer)
    @item2 = Item.find_by_id(item2)
    @owner = User.find_by_id(owner)
    sendgrid_ganalytics_options(@owner.utm_params) if @owner.tracking_info.present?
    mail(:to => @offerer.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def offer_made_owner(item1,offerer,item2,owner)
    sendgrid_category "Received Item Offer"
    @item1 = Item.find_by_id(item1)
    @offerer = User.find_by_id(offerer)
    @item2 = Item.find_by_id(item2)
    @owner = User.find_by_id(owner)
    sendgrid_ganalytics_options(@owner.utm_params) if @owner.tracking_info.present?
    @subject = "You Got An Offer From " + @offerer.first_name.titleize + " On Your " + @item2.title + "!"
    mail(:to => @owner.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def offer_accepted_offerer(item1,offerer,item2,owner)
    sendgrid_category "Accepted Item Offer to Offerer"
    @item1 = Item.find_by_id(item1)
    @offerer = User.find_by_id(offerer)
    @item2 = Item.find_by_id(item2)
    @owner = User.find_by_id(owner)
    sendgrid_ganalytics_options(@owner.utm_params) if @owner.tracking_info.present?
    @subject = "Congratulations! Your Offer On " + @item2.title + " Has Been Accepted! "
    mail(:to => @offerer.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def offer_accepted_owner(item1,offerer,item2,owner)
    sendgrid_category "Accepted Item Offer to Owner"
    @subject = "It's A Trade!".html_safe
    @item1 = Item.find_by_id(item1)
    @offerer = User.find_by_id(offerer)
    @item2 = Item.find_by_id(item2)
    @owner = User.find_by_id(owner)
    sendgrid_ganalytics_options(@owner.utm_params) if @owner.tracking_info.present?
    mail(:to => @owner.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def offer_rejected_offerer(item1,offerer,item2,owner)
    sendgrid_category "Rejected Item Offer to Offerer"
    @item1 = Item.find_by_id(item1)
    @offerer = User.find_by_id(offerer)
    @item2 = Item.find_by_id(item2)
    @owner = User.find_by_id(owner)
    sendgrid_ganalytics_options(@owner.utm_params) if @owner.tracking_info.present?
    @subject = "No Deal With " + @owner.first_name.titleize + " For " + @item2.title + "."
    mail(:to => @offerer.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def review_reminder_offerer(offerer,owner)
    sendgrid_category "Item Review Reminder to Offerer"
    @offerer = User.find_by_id(offerer)
    @owner = User.find_by_id(owner)
    sendgrid_ganalytics_options(@owner.utm_params) if @owner.tracking_info.present?
    @subject = "How'd it go?".html_safe
    mail(:to => @offerer.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def review_reminder_owner(offerer,owner)
    sendgrid_category "Item Review to Owner"
    @offerer = User.find_by_id(offerer)
    @owner = User.find_by_id(owner)
    sendgrid_ganalytics_options(@owner.utm_params) if @owner.tracking_info.present?
    @subject = "How'd it go?".html_safe
    mail(:to => @owner.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def review_reminder_other_user(item1,reviewer,item2,other_user)
    sendgrid_category "Item Review Reminder to Other"
    @item1 = Item.find_by_id(item1)
    @reviewer = User.find_by_id(reviewer)
    @item2 = Item.find_by_id(item2)
    @other_user = User.find_by_id(other_user)
    sendgrid_ganalytics_options(@other_user.utm_params) if @other_user.tracking_info.present?
    @subject = @reviewer.first_name.titleize + " just posted a review of your trade!"
    mail(:to => @other_user.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def review_reminder_reviewer(item1,reviewer,item2,other_user)
    sendgrid_category "Item Review Reminder to Reviewer"
    @item1 = Item.find_by_id(item1)
    @reviewer = User.find_by_id(reviewer)
    @item2 = Item.find_by_id(item2)
    @other_user = User.find_by_id(other_user)
    sendgrid_ganalytics_options(@reviewer.utm_params) if @reviewer.tracking_info.present?
    @subject = @other_user.first_name.titleize + " just posted a review of your trade!"
    mail(:to => @reviewer.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

end
