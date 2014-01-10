class HomeController < ApplicationController
  before_filter :current_location, :except => [:invite]
  before_filter :require_user, :only => [:dashboard,:manage_tradeyas,
                                         :manage_offers,
                                         :edit_settings,
                                         :edit_verifications]
  caches_action :index, :layout => false
  # :cache_path => Proc.new { |c| c.params[:signed_in] = (not current_user.nil?);
  #   c.params[:show_hello] = session[:show_hello]; c.params}
  # caches_action :test_ad_tags

  #--------------------------------------------------------------------------#
  # index ----> "Tradeya Home page"
  # Params --- IN:
  # +params[:guest_user_signup]+::"For guest user signup"
  # +params[:guest_user_token]+:: "Token for guest user"
  # Params --- OUT:
  # +@home_tradeyas+:: "Recent updated 15 items showing on home page"
  #--------------------------------------------------------------------------#
  def index
    # @recent_tradeyas = AcceptedOffer.recent_completed_tradeyas(5)
    # # @tradeyas = Item.current_tradeyas
    # @tradeyas = Item.featured_tradeyas
    # @tradeyas_by_category = Item.current_category_tradeyas
    # @current_category = Category.find_by_id(@tradeyas_by_category.first.category_id)
    # @tile_images = AcceptedOffer.get_tile_images
    # @recent_tradeyas = AcceptedOffer.check_default_case(AcceptedOffer.find_by_ids(InfoAndSetting.completed_trades))
    # @tradeyas = Item.check_default_case(Item.find_by_ids(InfoAndSetting.featured_tradeyas))
    # @tradeyas_by_category = Item.check_default_case(Item.find_by_ids(InfoAndSetting.current_cat_tradeyas))
    # @current_category = Category.find_by_id(@tradeyas_by_category.first.category_id)
    # @home_tradeyas = Item.find(:all, :order => "created_at desc", :limit => 15)
    #@home_tradeyas = Item.joins(:item_photos).find(:all, :order => "created_at desc", :limit => 15)
    within = nil
    if session[:within].present? then within = session[:within].to_i end
    search_result = Item.item_search(nil, nil, nil, nil, nil, 1, session[:user_ll], within, 15)
    @home_tradeyas = search_result.results if search_result.present?
    if params[:guest_user_signup] and params[:guest_user_token]
      @user = User.find_by_guest_user_token(params[:guest_user_token])
    end
    respond_to do |format|
      format.html
      format.json { head :ok }
    end
  end

  def dashboard
    @user_alert_count = Alert.user_alert_count(current_user.id)
    @new_alert_count = Alert.user_new_alert_count(current_user.id)
    if params[:page].nil? then session[:last_alert_id] = nil end
    @alerts = Alert.user_alerts(current_user.id, params[:page], session[:last_alert_id], params[:alert_filter])
    @new = false
    if params[:page].nil? and @alerts.count > 0
      session[:last_alert_id] = @alerts[0].id
    end
    session[:alert_filter] = params[:alert_filter]

    @v_phone_numbers = []
    if current_user.phone_verified?
      @v_phone_numbers = current_user.phone_numbers
    end
    @user_tradeyas_count = current_user.get_user_live_tradeya_count #Item.get_user_tradeyas_count(current_user.id)
    # @fb_friend_count = fb_friends_count(current_user)
    # @twitter_friend_count = twitter_friends_count(current_user)
    # @linkedin_friend_count = linkedin_friends_count(current_user)
    ###########################
    @fb_friend_count = current_user.fb_friends_count
    @twitter_friend_count = current_user.tw_friends_count
    @linkedin_friend_count = current_user.ln_friends_count

    # remove these unwanted parameters ASAP
    @reviews = User.get_user_reviews(current_user.id)
    @refresh_notification_count_on_greet = false

    respond_to do |format|
      format.html
      format.json { head :ok }
      format.js
    end
  end

  def manage_tradeyas
    @current_tradeyas = Item.get_user_tradeyas(current_user.id)
    @tradeya_history = Item.get_tradeya_history(current_user.id)

    respond_to do |format|
      format.html
      format.json { head :ok }
    end
  end

  def manage_offers
    @currentOffers = Trade.get_user_current_offers(current_user.id)
    @successfulOffers = Trade.get_user_successful_offers(current_user.id)
    @pastOffers = Trade.get_user_past_offers(current_user.id)

    respond_to do |format|
      format.html
      format.json { head :ok }
    end
  end

  def edit_settings
    respond_to do |format|
      format.html
      format.json { head :ok }
    end
  end

  def edit_verifications
    if current_user.is_guest_user
      redirect_to dashboard_url
    else
      @v_phone_numbers = current_user.phone_numbers

      respond_to do |format|
        format.html
        format.json { head :ok }
      end
    end
  end

  def mark_alert_read_and_redirect
    a = Alert.find(params[:id])
    a.is_new = false
    a.save

    if params[:redirect_url] && params[:redirect_url].length > 0
      redirect_to params[:redirect_url]
    else
      @user_alert_count = Alert.user_alert_count(current_user.id)
      @new_alert_count = Alert.user_new_alert_count(current_user.id)

      respond_to do |format|
        format.js
      end
    end
  end

  def refresh_alert_count_and_show_new
    if current_user
      @new = true

      @user_alert_count = Alert.user_alert_count(current_user.id)
      @new_alert_count = Alert.user_new_alert_count(current_user.id)
      @alerts = Alert.get_new_alerts(current_user.id, session[:last_alert_id], session[:alert_filter])
      if @alerts.count > 0
        session[:last_alert_id] = @alerts[0].id
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def refresh_user_greet_notification_count
    if current_user
      @new_alert_count = Alert.user_new_alert_count(current_user.id)
    end

    respond_to do |format|
      format.js
    end
  end

  def clear_cache
    expire_fragment "*/?signed_in=*"
    expire_fragment "*/modals?*"

    render :text => 'cleared'
  end

  def test_ad_tags
    render :layout => false
  end

  def contest
    if session[:ipad_mini_contest].nil? or not current_user
      session[:ipad_mini_contest] = 1
    elsif current_user and session[:ipad_mini_contest] <= 4
      session[:ipad_mini_contest] = session[:ipad_mini_contest] + 1
    end
    render :layout => "contest"
  end

  def contest_send_mail
    emails = ""
    regex = /([[\w]+[\s]*]+<[\w.]+@[\w]+[.][\w]+>)|([\w]+@[\w]+[.][\w]+)/
    if !params[:contact_list].blank?
      emails = params[:contact_list].gsub(';',',')
      emails = emails.scan(regex).map{|e| e}.join(",").split(",").delete_if(&:empty?).join(", ")
    end
    begin
      if emails.present? and current_user
        contest_data = ContestData.create(:user_id=>current_user.id, :emails => emails)
        EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_CONTEST_EMAIL, current_user.id, {:contest_data_id => contest_data.id})
      end
    rescue StandardError => e
    end
    redirect_to contest_url
  end

  def contest_share
    if current_user
      cotest_data = ContestData.find(:first, :conditions => ["user_id = ?",current_user.id])
      if contest_data
        contest_data.update_attributes(:fb_share => true)
      else
        contest_data = ContestData.create(:user_id=>current_user.id, :fb_share => true)
      end
    end
    render :text => "success"
  end

  def invite
    if current_user.present?
      redirect_to items_path + "?category=all"
    else
      render :layout => false
    end
  end

  def welcome
    if current_user.present?
      redirect_to items_path + "?category=all"
    else
      render :layout => false
    end
  end

  def holiday
    if current_user.present?
      redirect_to items_path + "?category=all"
    else
      render :layout => false
    end
  end

  def getstarted
    if current_user.present?
      redirect_to items_path + "?category=all"
    else
      render :layout => false
    end
  end
end
