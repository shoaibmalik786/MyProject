class ItemMailer < ActionMailer::Base
  include Resque::Mailer
  include SendGrid
  sendgrid_enable   :ganalytics

  default from: "jared@tradeya.com"

  def item_added_first(item,user)
    sendgrid_category "Item Added"
    @item = Item.find_by_id(item)
    @user = User.find_by_id(user)
    sendgrid_ganalytics_options(@user.utm_params) if @user.tracking_info.present?
    @subject = "Success! You've Added your ".html_safe + @item.title + " To TradeYa!".html_safe
    mail(:to => @user.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def item_added(item,user)
    sendgrid_category "Item Added"
    @item = Item.find_by_id(item)
    @user = User.find_by_id(user)
    sendgrid_ganalytics_options(@user.utm_params) if @user.tracking_info.present?
    @subject = "Success! You've Added your ".html_safe + @item.title + " To TradeYa!".html_safe
    mail(:to => @user.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def item_liked(item,user)
    sendgrid_category "Item Liked"
    @item = Item.find_by_id(item)
    @user = User.find_by_id(user)
    sendgrid_ganalytics_options(@user.utm_params) if @user.tracking_info.present?
    @subject = @user.title + " likes your " + @item.title + "!"
    mail(:to => @item.user.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def item_wanted_first_less_haves(item,user)
    sendgrid_category "Item Wanted"
    @item = Item.find_by_id(item)
    @user = User.find_by_id(user)
    sendgrid_ganalytics_options(@user.utm_params) if @user.tracking_info.present?
    @subject = "Success! You've added ".html_safe + @item.title + " to your Wants Board!".html_safe
    mail(:to => @user.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def item_wanted_first_more_haves(item,user)
    sendgrid_category "Item Wanted"
    @item = Item.find_by_id(item)
    @user = User.find_by_id(user)
    sendgrid_ganalytics_options(@user.utm_params) if @user.tracking_info.present?
    @subject = "Success! You've added ".html_safe + @item.title + " to your Wants Board!".html_safe
    mail(:to => @user.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def item_wanted_less_haves(item,user)
    sendgrid_category "Item Wanted"
    @item = Item.find_by_id(item)
    @user = User.find_by_id(user)
    sendgrid_ganalytics_options(@user.utm_params) if @user.tracking_info.present?
    @subject = "Success! You've added ".html_safe + @item.title + " to your Wants Board!".html_safe
    mail(:to => @user.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def item_wanted_more_haves(item,user)
    sendgrid_category "Item Wanted"
    @item = Item.find_by_id(item)
    @user = User.find_by_id(user)
    sendgrid_ganalytics_options(@user.utm_params) if @user.tracking_info.present?
    @subject = "Success! You've added ".html_safe + @item.title + " to your Wants Board!".html_safe
    mail(:to => @user.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def item_wanted_first_owner(item,user)
    sendgrid_category "Item Wanted"
    @item = Item.find_by_id(item)
    @user = User.find_by_id(user)
    sendgrid_ganalytics_options(@user.utm_params) if @user.tracking_info.present?
    @subject = @user.title + " wants your " + @item.title + "!"
    mail(:to => @item.user.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def item_wanted_owner(item,user)
    sendgrid_category "Item Wanted"
    @item = Item.find_by_id(item)
    @user = User.find_by_id(user)
    sendgrid_ganalytics_options(@user.utm_params) if @user.tracking_info.present?
    @subject = @user.title + " wants your " + @item.title + "!"
    mail(:to => @item.user.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def comment_received(item,commenter)
    sendgrid_category "Item Comment"
    @item = Item.find_by_id(item)
    @commenter = User.find_by_id(commenter)
    sendgrid_ganalytics_options(@commenter.utm_params) if @commenter.tracking_info.present?
    @subject = @commenter.title + " made a comment on your " + @item.title + "."
    mail(:to => @item.user.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def reply_comment_received(item,commenter,comment,other_commenter)
    sendgrid_category "Reply Item Comment"
    @item = Item.find_by_id(item)
    @commenter = User.find_by_id(commenter)
    sendgrid_ganalytics_options(@commenter.utm_params) if @commenter.tracking_info.present?
    @other_commenter = User.find_by_id(other_commenter)
    @comment = Comment.find(comment)
    @subject = @commenter.title + " also commented on " + @item.title + "."
    mail(:to => @other_commenter.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

  def request_for_more_info(request_info)
    sendgrid_category "Request Info"
    @request_info = RequestInfoItem.find(request_info)
    @item = Item.find_by_id(@request_info.item_id)
    @requester = User.find_by_id(@request_info.user_id)
    sendgrid_ganalytics_options(@requester.utm_params) if @requester.tracking_info.present?
    @subject = @requester.title + " has a question about your " + @item.title + "."
    mail(:to => @item.user.email, :reply_to => @requester.email, :subject => @subject, :from => 'TradeYa <jared@tradeya.com>', :content_type => "text/html")
  end

end
