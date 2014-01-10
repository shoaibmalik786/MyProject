class UserMailer < ActionMailer::Base
  include Resque::Mailer
  include SendGrid
  sendgrid_enable   :ganalytics

  default from: "jared@tradeya.com"

  def user_followed(follower,followed)
    sendgrid_category "User Follow"
    @Follower = User.find_by_id(follower)
    @followed = User.find_by_id(followed)
    @subject = @follower.title + " is now following you on TradeYa!".html_safe
    sendgrid_ganalytics_options(@followed.utm_params) if @followed.tracking_info.present?
    mail(:to => @followed.email, :subject => @subject, :from => 'TradeYa <Support@TradeYa.com>', :content_type => "text/html")
  end

  def sneak_peak
    sendgrid_category "Sneak Peak"
    @subject = "Have you seen this yet? [sneak peak]"
    mail(:to => 'jk@tradeya.com, prateek.attree@addvalsolutions.com',
         :subject => @subject,
         :from => 'TradeYa <jared@tradeya.com>',
         :content_type => "text/html")
  end

  def friends_joined(friend,user)
    sendgrid_category "Friend Joined"
    @user = User.find_by_id(user)
    sendgrid_ganalytics_options(@user.utm_params) if @user.tracking_info.present?
    @friend = User.find_by_id(friend)
    @subject = "Your friend has joined!"
    mail(:to => @user.email, :subject => @subject, :from => 'TradeYa <Support@TradeYa.com>', :content_type => "text/html")
  end
  
end
