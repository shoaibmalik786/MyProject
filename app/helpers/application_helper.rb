module ApplicationHelper
  require 'httparty'

  USED_CONDITION = 1
  NEW_CONDITION = 2

  MEET_UP = 1
  DELIVERY_ONLY = 2
  PICK_UP_ONLY = 3
  YOUR_PLACE = 4
  MY_PLACE = 5
  REMOTELY = 6

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def resource_class
    User
  end

  def encode( string )
    URI.escape( string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]") ).gsub('*', '%2A')
  end

  def client_browser_name
    user_agent = ""
    if request.env['HTTP_USER_AGENT'] then user_agent = request.env['HTTP_USER_AGENT'].downcase end
    if user_agent =~ /msie/i
      "Internet Explorer"
    elsif user_agent =~ /konqueror/i
      "Konqueror"
    elsif user_agent =~ /firefox/i
      "Mozilla"
    elsif user_agent =~ /gecko/i or user_agent =~ /chrome/i
      "Chrome"
    elsif user_agent =~ /opera/i
      "Opera"
    elsif user_agent =~ /applewebkit/i
      "Safari"
    else
      "Unknown"
    end
  end

  def isMSIE?
    if client_browser_name == "Internet Explorer"
      return true;
    else
      return false;
    end
  end

  def isMozilla?
    if client_browser_name == "Mozilla"
      return true;
    else
      return false;
    end
  end

  def userHover(u)
    if u.active?
      profile_show = ((u.goods_sub_cat_ids.length > 0) or u.interests_sub_cat_ids.length > 0 or u.services_sub_cat_ids.length>0 or (!u.wish.nil? and u.wish.length > 0))
      fb = !u.authentication('facebook').nil?
      fb_frnds = (fb) ? u.fb_friends_count : 0
      show_mutual_conn = true
      if current_user and fb
        if current_user.id == u.id
          show_mutual_conn = false
          mutual_conn = 0
        else
          mutual_conn = MutualFriend.get_mutual_friends_count(current_user.id,u.id)
        end
      else
        mutual_conn = 0
      end
      goods = (profile_show) ? escape_javascript(u.goods_str) : ""
      services = (profile_show) ? escape_javascript(u.services_str) : ""
      interests = (profile_show) ? escape_javascript(u.interests_str) : ""
      wish = (profile_show) ? escape_javascript(u.wish) : ""
      a_tag = ""
      #tradeya_count = u.get_user_live_tradeya_count
      if u.tradeya_count == 1
        a_tag = "<a href = \'/items?u=" + u.id.to_s + "\'>See 1 " + u.first_name_with_s + " TradeYa</a>"
      elsif u.tradeya_count > 1
        a_tag = "<a href = \'/items?u=" + u.id.to_s + "\'>See all " + u.tradeya_count.to_s + " of " + u.first_name_with_s + " TradeYas</a>"
      end
      return "hoverUserProfile(this,'" + u.user_image("medium") + "', '" + escape_javascript(u.title) + "', '" + u.location + "'," + profile_show.to_s + "," + (u.phone_verified?).to_s + "," + fb.to_s + "," + fb_frnds.to_s + "," + mutual_conn.to_s + ",'" + goods + "','" + services + "','" + interests + "','" + wish + "',\"" + a_tag.html_safe + "\"," + show_mutual_conn.to_s + ");"
    end
  end

  def time_ago(time)
    current_time = Time.now
    duration = ((current_time - time)/1.day).floor
    if duration > 0
      return duration.to_s + ((duration == 1)? " day": " days") + " ago"
    else
      duration = ((current_time - time)/1.hour).floor
      if duration > 0
        return duration.to_s + ((duration == 1)? " hour": " hours") + " ago"
      else
        duration = ((current_time - time)/1.minute).floor
        if duration > 0
          return duration.to_s + ((duration == 1)? " minute": " minutes") + " ago"
        else
          duration = ((current_time - time)/1.second).floor
          if duration > 0
            return duration.to_s + ((duration == 1)? " second": " seconds") + " ago"
          end
        end
      end
    end
  end

  def getToolTipImage(type)
    case type
    when TOOL_TIP_NEW_OFFER; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_new_offer.png'
    when TOOL_TIP_RE_USE_OFFER; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_reuse_offer.png'
    when TOOL_TIP_NEW_TRADEYA; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_newtradeya.png'
    when TOOL_TIP_POSTPONE_TRADEYA; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_postponetradeya.png'
    when TOOL_TIP_SPREAD_THE_WORD; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/spreadtheword.png'
    when TOOL_TIP_TIME_IS_TICKLING; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/timeticking.png'
    when TOOL_TIP_RESUBMIT_POSPONED_TRADEYA; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_resubmit_postponed.png'
    when TOOL_TIP_RESUBMIT_EXPIRED_TRADEYA; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_resubmit_expired.png'
    when TOOL_TIP_PUBLISHER_OFFER_1; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_publisher_offer_1.png'
    when TOOL_TIP_PUBLISHER_OFFER_2; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_publisher_offer_2.png'
    when TOOL_TIP_OFFER_PAGE; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/asterisk.png'
    when TOOL_TIP_OFFER_PAGE_RIGHT; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/asterisk_right.png'
    when TOOL_TIP_NEW_TRADEYA_RIGHT; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_newtradeya_right.png'
    when TOOL_TIP_POSTPONE_TRADEYA_RIGHT; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_postponetradeya_right.png'
    when TOOL_TIP_SPREAD_THE_WORD_RIGHT; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/spreadtheword_right.png'
    when TOOL_TIP_RESUBMIT_POSPONED_TRADEYA_RIGHT; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_resubmit_postponed_right.png'
    when TOOL_TIP_RESUBMIT_EXPIRED_TRADEYA_RIGHT; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_resubmit_expired_right.png'
    when TOOL_TIP_NEW_OFFER_RIGHT; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_new_offer_right.png'
    when TOOL_TIP_RE_USE_OFFER_RIGHT; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_reuse_offer_right.png'
    when TOOL_TIP_PUBLISHER_OFFER_1_RIGHT; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_publisher_offer_1_right.png'
    when TOOL_TIP_PUBLISHER_OFFER_2_RIGHT; return 'https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/tip_publisher_offer_2_right.png'
    end
  end

  def current_class?(test_path, class_style)
    return class_style if request.fullpath == test_path
    ''
  end
end
