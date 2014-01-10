class UsersController < ApplicationController
  require 'will_paginate/array'
  require 'RMagick'
  include Magick
  helper_method :mailbox
  before_filter :current_location
  
  skip_before_filter :verify_authenticity_token,
  :if => Proc.new { |c| c.request.format == 'application/json' }
  before_filter :authenticate_user!, :only => [:follow, :show, :index, :edit, :haves, :likes, :wants, :following,
                                               :past_trades, :reviews, :myoffers, :activity_feed]
  respond_to :json

  # before_filter :require_user, :only => [:show, :index, :haves, :likes, :wants, :following,
  #                                        :past_trades, :reviews, :myoffers, :activity_feed]

  #--------------------------------------------------------------------------#
  # follow ----> "follow/Unfollow a user"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # +params[:follow]+:: " Boolean indicating follow or unfollow"
  # Params --- OUT:
  # +@item+:: item object based on params[:id]
  #--------------------------------------------------------------------------#
  def follow
    @user = User.find_by_id(params[:id])
    if current_user.id != params[:id].to_i
      find_follow = current_user.follows.where(:followed_id => params[:id],
                                               :follower_id => current_user.id)

      if params[:follow] == "false"
        if !find_follow.blank?
          find_follow.delete_all
        end
      else
        if find_follow.blank?
          current_user.follows.create(:followed_id => params[:id] )
        # Send follow email
        # UserMailer.user_followed(current_user.id,@user.id).deliver
        end
      end
    end
    if params[:follow_tab]
      @user = current_user
    end
    @item = (params[:item_id])? Item.find(params[:item_id]) : nil
    respond_to do |format|
      format.js
      format.html { redirect_to (@item)? @item.item_path : @user }
      format.json {
        render :status => 200,
        :json => { :success => true,
          :info => "follow/unfollow success!",
          :data => {} }
      }
    end
  end

  #--------------------------------------------------------------------------#
  # show ----> "User's Index page"
  # Params --- IN:
  # Params --- OUT:
  #--------------------------------------------------------------------------#
  def index
    within = nil
    if session[:within].present? then within = session[:within].to_i end
    page = 1
    if params[:page] then page = params[:page].to_i end
    begin
      if params[:search].present?
        @results_for = params[:search]
        if params[:sort_by].present? and params[:sort_by] != "most recent"
          #sort by distance
          search_result = User.user_search(params[:search], params[:sort_by], params[:page], session[:user_ll], within, nil)
        else
          #sort by Most Recent
          search_result = User.user_search(params[:search], nil, params[:page], session[:user_ll], within, nil)
        end
        if search_result.present?
          @users = search_result.results
          @distance = User.calculate_distance(@users,session[:user_ll])
          @i_total = search_result.total
        else
          @users =[]
          @i_total = 0
        end
      else
        @results_for = "All Users"
        if params[:sort_by].present? and params[:sort_by] != "most recent"
          #sort by distance
          search_result = User.user_search(nil, params[:sort_by], params[:page], session[:user_ll], within, nil)
        else
          #sort by Most Recent
          search_result = User.user_search(nil, nil, params[:page], session[:user_ll], within, nil)
        end
        if search_result.present?
          @users = search_result.results
          @distance = User.calculate_distance(@users,session[:user_ll])
          @i_total = search_result.total
        else
          @users =[]
          @i_total = 0
        end
      end
    rescue StandardError => e
      @users = []
      @i_total = 0
    end
    respond_to do |format|
      if params[:page]
        format.js
      else
        format.html # index.html.erb
        format.json { render json: @users }
      end
    end
  end

  #--------------------------------------------------------------------------#
  # show ----> "User's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  #--------------------------------------------------------------------------#
  def show

    if params[:id].present?
      if params[:tab].blank? and params[:id] == current_user.id
        redirect_to dashboard_user_path(params[:id]) #,:wanted_item => params[:wanted_item])
      else 
        redirect_to haves_user_path(params[:id],:wanted_item => params[:wanted_item])
      end

      @user = User.find_by_id(params[:id])
      if @user.present?
        @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
        @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
        @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
        @user_images = @user.user_all_image(:large)
      end
    end
  end

  def edit
    @user = current_user
    
  end

  def update
    if current_user
      @user = current_user
      @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
      @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
      @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
      @user_images = @user.user_all_image(:large)
    end
    respond_to do |format|
      if current_user and @user.update_attributes(params[:user])
        #debugger
        format.html {redirect_to @user, notice: 'Profile was successfully updated.'}
        format.js 
        format.json {head :ok}
      else
        format.html {render action: "edit"}
        format.js
        format.json {render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def invite
    @user = User.find_by_id(params[:id])
    @user_invitations = @user.invitations
    if current_user.present? and current_user.superadmin?
      @self_invites = User.self_invites
    end
  end

  def check_email
    if params[:user].present? and params[:user][:email].present?
      user_email = User.find_by_email(params[:user][:email])
      if user_email.present?
        render :nothing => true, :status => 200
      else
        render :nothing => true, :status => 409
      end
    end
  end

  def resend_invite
    if user_signed_in?
      user = User.find(params[:user])
      user.invite!(current_user)
    else
      User.invite!(params[:user]) do |u|
        u.skip_invitation = true
      end
    end
    respond_to do |format|
      format.js {
        if user_signed_in?
          flash[:notice] = "Invitation to #{user.first_name.titleize} has been resent."
        end
        # (render(:partial => 'shared/thankyou', :layout => false) && return)  if request.xhr?
        (render(:text => 'thank you', :layout => false) && return)  if request.xhr?
      }

      format.html {
        flash[:notice] = "Invitation to #{user.first_name.titleize} has been resent."
        redirect_to invite_user_path(current_user)
      }
    end
  end

  def resend_invite_to_all
    if current_user.present?
      all_invitations = current_user.invitations
      all_invitations.each do |invited_user|
        if invited_user.invitation_accepted_at.nil?
          pending_invite_user = User.find(invited_user)
          pending_invite_user.invite!(current_user)
        end
      end
    end
    respond_to do |format|
      format.js {
        if user_signed_in?
          flash[:notice] = "Invitations to all pending users have been resent."
        end
        # (render(:partial => 'shared/thankyou', :layout => false) && return)  if request.xhr?
        (render(:text => 'thank you', :layout => false) && return)  if request.xhr?
      }

      format.html {
        flash[:notice] = "Invitations to all pending users have been resent."
        redirect_to invite_user_path(current_user)
      }
    end
  end

  def reinvite
    user = User.find_by_email(params[:user][:email])
    if user
      user_signed_in? ? user.invite(current_user) : user.invite!
    else
      User.invite!(params[:user]) do |u|
        u.skip_invitation = true
      end
    end

    respond_to do |format|
      format.js {
        if current_user.present? and user.present?
          flash[:notice] = "Invitation to #{user.first_name.titleize} has been resent."
        end
        # (render(:partial => 'shared/thankyou', :layout => false) && return)  if request.xhr?
        (render(:text => 'thank you', :layout => false) && return)  if request.xhr?
      }

      format.html {
        if current_user.present? and user.present?
          flash[:notice] = "Invitation to #{user.first_name.titleize} has been resent."
          redirect_to invite_user_path(current_user)
        end
      }
    end
  end

  #--------------------------------------------------------------------------#
  # Dashboard Tab ----> "Dasboard tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  # +@wanted_items+:: returns array of user's wants
  #--------------------------------------------------------------------------#
  def dashboard
    if params[:id].present?
      @user = User.find_by_id(params[:id])
      @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
      @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
      @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
      @user_images = @user.user_all_image(:large)
      @activity_feed = @user.activity_feed(params[:sort_by]) #.paginate(:page => params[:page], :per_page => 5)
      @alert_activities = Item.where(:user_id => @user.id, :status => "LIVE").includes(:wants).where('wants.id is not null and alert = 1').order("wants.created_at DESC")
      @dashboard_items = DashboardQuestion.where("question_status < ?", 4)
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def my_wants
    if params[:id].present?
      @user = User.find_by_id(params[:id]) 
      @my_wants = Item.joins(:wants).where('wants.user_id' => "#{@user.id}",'items.status'=>'LIVE').order("wants.created_at DESC")

      if params[:remove_want].present?
        find_want = Want.find_by_item_id_and_user_id(params[:remove_want],params[:id])
        if find_want.present?
          find_want.destroy
        end
      end
    end
  end

  def wants_on_my_haves
    if params[:id].present?
      @user = User.find_by_id(params[:id]) 
      @wants_on_my_haves = Item.where(:user_id => @user.id, :status => "LIVE").includes(:wants).where('wants.id is not null').order("wants.created_at DESC")
    end
  end
  
  #--------------------------------------------------------------------------#
  # Wants_tab ----> "Wants tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  # +@wanted_items+:: returns array of user's wants
  #--------------------------------------------------------------------------#
  def wants
    if params[:id].present?
      @user = User.find_by_id(params[:id])
      @wanted_items = @user.wanted_items
      if @wanted_items.blank?
        search_center = [34.0126379,-118.495155]
        search_result = Item.item_search(nil, nil, "most offered",nil,nil, 1, search_center, nil,10)
        @items = search_result.results
        @distance = Item.calculate_distance(@items,session[:user_ll])
      end
      @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
      @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
      @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
      @user_images = @user.user_all_image(:large)
    end
    respond_to do |format|
      format.js
      format.html
    end
  end


  #--------------------------------------------------------------------------#
  # haves_tab ----> "Haves tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  # +@have_items+:: returns array of user's haves
  #--------------------------------------------------------------------------#
  def haves
    if params[:id].present?
      @user = User.find_by_id(params[:id])
      @have_items = @user.have_items if @user.present?
      @user_images = @user.user_all_image(:large) if @user.present?
      @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
      @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
      @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
      if params[:wanted_item].present?
        @wanted_item = Item.find_by_id(params[:wanted_item].to_i)
        flash[:error] = "Check out " + @user.first_name.titleize + "'s stuff. If you see something you want to trade for your \"" + @wanted_item.title + "\" rollover the card and click on TRADE to make an offer."
      end
    end
    respond_to do |format|
      format.js
      format.html
    end
  end


  #--------------------------------------------------------------------------#
  # likes_tab ----> "Likes tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  # +@liked_items+:: returns array of user's likes
  #--------------------------------------------------------------------------#
  def likes
    if params[:id].present?
      @user = User.find_by_id(params[:id])
      @liked_items = @user.liked_items if @user.present?
      if @liked_items.blank?
        search_center = [34.0126379,-118.495155]
        search_result = Item.item_search(nil, nil, "most offered", nil,nil,1, search_center, nil,10)
        @items = search_result.results
        @distance = Item.calculate_distance(@items,session[:user_ll])
      end
      @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
      @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
      @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
      @user_images = @user.user_all_image(:large)
    end
    respond_to do |format|
      format.js
      format.html
    end
  end


  #--------------------------------------------------------------------------#
  # past_trades_tab ----> "Past Trades tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  #--------------------------------------------------------------------------#
  def past_trades
    if params[:id].present?
      @user = User.find_by_id(params[:id])
      @past_trades = @user.past_trades
      if @past_trades.count <= 0
        search_center = [34.0126379,-118.495155]
        search_result = Item.item_search(nil, nil, "most offered", nil,nil,1, search_center, nil,10)
        @items = search_result.results
        @distance = Item.calculate_distance(@items,session[:user_ll])
      end
      @user_images = @user.user_all_image(:large)
      @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
      @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
      @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
    end
  end


  #--------------------------------------------------------------------------#
  # reviews_tab ----> "Reviews tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  # +@user+:: returns user based on params[:id]
  #--------------------------------------------------------------------------#
  def reviews
    if params[:id].present?
      @user = User.find_by_id(params[:id])

      @unreview_trades = @user.unreview_trades
      @user_reviews = @user.user_reviews.all(:order => "overall_rating desc")
      @reviews_of_user = @user.reviews.all(:order => "overall_rating desc")
      @user_images = @user.user_all_image(:large)
      @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
      @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
      @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
      @description_sections = @user.get_review_buckets(:describe_rating)
      @communication_sections = @user.get_review_buckets(:communication_rating)
      
      if @description_sections.present?
        @description_largest = @description_sections.max_by{|k,v| v}.second
      else 
        @description_sections = { 5=>0, 4=>0, 3=>0, 2=>0, 1=>0, 0=>0 }
      end
      if @communication_sections.present?
        @communication_largest = @communication_sections.max_by{|k,v| v}.second
      else
        @communication_sections = { 5=>0, 4=>0, 3=>0, 2=>0, 1=>0, 0=>0 }
      end
      
      if params[:review_reminder].present?
        flash[:error] = "Review your trade experience here. TradeYa is built on trust and your review helps the entire community work more smoothly."
      end
    end
  end

  #--------------------------------------------------------------------------#
  # following_tab ----> "Following tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  # +@followed_items+:: returns array of following users followed by @user
  #--------------------------------------------------------------------------#
  def following
    if params[:id].present?
      @user = User.find_by_id(params[:id])
      @users_display = @user.following_users
      @user_images = @user.user_all_image(:large)
      @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
      @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
      @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
      @show_twitter_modal =  false

      # facebook friends
        if current_user and current_user == @user and @user.facebook_authenticated?
          @facebook_friends = @user.facebook_friends
          fb_uids = @facebook_friends.collect{ |f| f["id"] }
          @fb_friends_authentications  = @user.fb_friends_authentications(fb_uids)
          @facebook_registered_friends = @fb_friends_authentications.collect{ |f| f["user_id"] }
        end


      # twitter friends
      begin
        if current_user and current_user = @user and @user.twitter_authenticated?
          @twitter_friends = @user.twitter_friends
          tw_uids = @twitter_friends.collect{ |t| t.to_s}
          @tw_friends_authentications = @user.tw_friends_authentications(tw_uids)
          @twitter_registered_friends = @tw_friends_authentications.collect{ |f| f["user_id"] }
        end
      rescue StandardError => e
        @tw_friends_authentications = nil
        @twitter_registered_friends = nil
        @show_twitter_modal = true
      end

      #all friends - friends to follow
      if @facebook_registered_friends.present?
        if @twitter_registered_friends.present?
          @all_friends_authentications = @fb_friends_authentications + @tw_friends_authentications
          @all_friends_authentications.sort! { |a,b| b.created_at <=> a.created_at }
        else
          @all_friends_authentications = @fb_friends_authentications
        end
      else
        if @twitter_registered_friends.present?
          @all_friends_authentications = @tw_friends_authentications
        else
          @all_friends_authentications = []
        end
      end

      # pick top 6 friends to follow - the ones which are not followed yet
      # if @all_friends_authentications.present?
      #   if @followed_items.present?
      #     @all_friends = []
      #     @followed_item_ids = @followed_items.pluck(:followed_id)
      #     count = 0
      #     @all_friends_authentications.each do |a|
      #       if @followed_item_ids.exclude?(a.user_id)
      #         @all_friends[count] = a
      #         count += 1
      #       end
      #     end
      #   else
      #     @all_friends = @all_friends_authentications
      #   end
        if @all_friends_authentications.present?
          @all_friends_authentications = @all_friends_authentications.take(6)
        else
          @all_friends_authentications = []
        end
      # end

    end
  end


  def followers 
    if params[:id].present?
      @user = User.find_by_id(params[:id])      
      @users_display = @user.followed_by_users
      @user_images = @user.user_all_image(:large)
      @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
      @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
      @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
      @show_twitter_modal =  false
      @followers = true;

      # facebook friends
      if current_user and current_user == @user and @user.facebook_authenticated?
        @facebook_friends = @user.facebook_friends
        fb_uids = @facebook_friends.collect{ |f| f["id"] }
        @fb_friends_authentications  = @user.fb_friends_authentications(fb_uids)
        @facebook_registered_friends = @fb_friends_authentications.collect{ |f| f["user_id"] }
      end


      # twitter friends
      begin
        if current_user and current_user = @user and @user.twitter_authenticated?
          @twitter_friends = @user.twitter_friends
          tw_uids = @twitter_friends.collect{ |t| t.to_s}
          @tw_friends_authentications = @user.tw_friends_authentications(tw_uids)
          @twitter_registered_friends = @tw_friends_authentications.collect{ |f| f["user_id"] }
        end
      rescue StandardError => e
        @tw_friends_authentications = nil
        @twitter_registered_friends = nil
        @show_twitter_modal = true
      end

      #all friends - friends to follow
      if @facebook_registered_friends.present?
        if @twitter_registered_friends.present?
          @all_friends_authentications = @fb_friends_authentications + @tw_friends_authentications
          @all_friends_authentications.sort! { |a,b| b.created_at <=> a.created_at }
        else
          @all_friends_authentications = @fb_friends_authentications
        end
      else
        if @twitter_registered_friends.present?
          @all_friends_authentications = @tw_friends_authentications
        else
          @all_friends_authentications = []
        end
      end

      # pick top 6 friends to follow - the ones which are not followed yet
      # if @all_friends_authentications.present?
      #   if @followed_items.present?
      #     @all_friends = []
      #     @followed_item_ids = @followed_items.pluck(:followed_id)
      #     count = 0
      #     @all_friends_authentications.each do |a|
      #       if @followed_item_ids.exclude?(a.user_id)
      #         @all_friends[count] = a
      #         count += 1
      #       end
      #     end
      #   else
      #     @all_friends = @all_friends_authentications
      #   end
      if @all_friends_authentications.present?
        @all_friends_authentications = @all_friends_authentications.take(6)
      else
        @all_friends_authentications = []
      end
      # end

    end
    render 'following'
  end
  
  def facebook_friends
    @user = User.find_by_id(params[:id])
    if params[:facebook_registered_friends].present?
      followed_friends_ids = @user.followed_items.collect{ |f| f["followed_id"].to_s }
      if followed_friends_ids.present?
        fb_friends_unfollowed = params[:facebook_registered_friends] - followed_friends_ids
        if fb_friends_unfollowed.present? then @fb_friends_unfollowed = User.find(fb_friends_unfollowed).sort! { |a,b| b.have_items.count <=> a.have_items.count } end
        fb_friends_followed = params[:facebook_registered_friends] - fb_friends_unfollowed
        if fb_friends_followed.present? then @fb_friends_followed = User.find(fb_friends_followed) end
      else
        @fb_friends_unfollowed = User.find(params[:facebook_registered_friends]).sort! { |a,b| b.have_items.count <=> a.have_items.count }
        @fb_friends_followed = nil
      end
    end
  end

  def twitter_friends
    @user = User.find_by_id(params[:id])
    if params[:twitter_registered_friends].present?
      followed_friends_ids = @user.followed_items.collect{ |f| f["followed_id"].to_s }
      if followed_friends_ids.present?
        tw_friends_unfollowed = params[:twitter_registered_friends] - followed_friends_ids
        if tw_friends_unfollowed.present? then @tw_friends_unfollowed = User.find(tw_friends_unfollowed).sort! { |a,b| b.have_items.count <=> a.have_items.count } end
        tw_friends_followed = params[:twitter_registered_friends] - tw_friends_unfollowed
        if tw_friends_followed.present? then @tw_friends_followed = User.find(tw_friends_followed) end
      else
        @tw_friends_unfollowed = User.find(params[:twitter_registered_friends]).sort! { |a,b| b.have_items.count <=> a.have_items.count }
        @tw_friends_followed = nil
      end
    end
  end

  def following_tab_search
    if params[:id].present?
    # search results
      if params[:search_user].present?
        #sort by Most Recent
        search_result = User.user_search(params[:search_user], nil, nil, session[:user_ll], nil, nil)
        if search_result.present?
          @user_search_results = search_result.results
        else
          @user_search_results =[]
        end
      end
    end
  end


  #--------------------------------------------------------------------------#
  # myoffers_tab ----> "My Offers tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  #--------------------------------------------------------------------------#
  def myoffers
    if params[:id].present?
      @user = User.find_by_id(params[:id])
      @trades_grouped_by_items = @user.my_offers_grouped_by_item
      @trades_count = @user.reverse_trades.where(:items => {:status => 'LIVE'}).with_live_item.count
      @user_images = @user.user_all_image(:large)
      @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
      @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
      @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
    end
  end


  #--------------------------------------------------------------------------#
  # activity_feed_tab ----> "activity feed tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  #--------------------------------------------------------------------------#
  def activity_feed
    if params[:id].present?
      @user = User.find_by_id(params[:id])
      @user_images = @user.user_all_image(:large)
      @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
      @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
      @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
      @activity_feed = @user.activity_feed(params[:sort_by]) #.paginate(:page => params[:page], :per_page => 5)

      @new_items_count = 0
      @activity_feed.each do |a|
        if (a.trackable_type == "Like" and ((a.recipient_id == current_user.id and !a.viewed_by_recipient) or (a.owner_id == current_user.id and !a.viewed_by_owner)))
          @new_items_count += 1
        elsif (a.trackable_type == "Comment" and a.recipient_id == current_user.id and !a.viewed_by_recipient)
          @new_items_count += 1
        elsif (a.trackable_type == "Item" and a.owner_id == current_user.id and !a.viewed_by_owner)
          @new_items_count += 1
        elsif (a.trackable_type == "Want" and ((a.recipient_id == current_user.id and !a.viewed_by_recipient) or (a.owner_id == current_user.id and !a.viewed_by_owner)))
          @new_items_count += 1
        end
      end
      redirect_to inbox_notifications_user_path(params[:id])
      # mailboxer inbox

      # @convs = current_user.mailbox.conversations(:mailbox_type => 'not_trash', :include => { :receipts => :notification })
      # @convs = current_user.mailbox.conversations(:include => { :receipts => :notification }) - current_user.mailbox.trash(:include => { :receipts => :notification })
      # @convs = @convs.sort_by! {|c| (c.receipts(current_user).where('mailbox_type != ? and receiver_id = ?','trash',current_user.id).last.created_at)}.reverse
      # @conv = @convs.first
      # debugger
      # if params[:conv_id].present?

      #     debugger
      #     @conv = Conversation.find(params[:id])
      #     @conv.receipts.each do |receipt|
      #     debugger
      #       if receipt.receiver_id == current_user.id
      #         receipt.is_read = true
      #         receipt.save
      #       end
      #     end

      # end


    end
  end

  def messaging
    if params[:id].present?
      @user = User.find_by_id(params[:id])
      unless @user.nil?
        @user_images = @user.user_all_image(:medium)
        @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
        @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
        @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
        @convs = current_user.mailbox.conversations(:include => { :receipts => :notification }) - current_user.mailbox.trash(:include => { :receipts => :notification })
      end
    end
  end

  def autocomplete
    @users = User.autocomplete_for(params[:q])
    render json: @users.to_json
  end

  # def notifications
  #   if params[:id].present?
  #     @user = User.find_by_id(params[:id])
  #     @user_images = @user.user_all_image(:medium)
  #     @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
  #     @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
  #     @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?

  #     @activity_feed = @user.activity_feed(params[:sort_by])#.paginate(:page => params[:page], :per_page => 5)

  #     @new_items_count = 0
  #     @activity_feed.each do |a|
  #       if (a.trackable_type == "Like" and ((a.recipient_id == current_user.id and !a.viewed_by_recipient) or (a.owner_id == current_user.id and !a.viewed_by_owner)))
  #         @new_items_count += 1
  #       elsif (a.trackable_type == "Comment" and a.recipient_id == current_user.id and !a.viewed_by_recipient)
  #         @new_items_count += 1
  #       elsif (a.trackable_type == "Item" and a.owner_id == current_user.id and !a.viewed_by_owner)
  #         @new_items_count += 1
  #       elsif (a.trackable_type == "Want" and ((a.recipient_id == current_user.id and !a.viewed_by_recipient) or (a.owner_id == current_user.id and !a.viewed_by_owner)))
  #         @new_items_count += 1
  #       end
  #     end
  #   end
  #   # @convs = current_user.mailbox.conversations(:include => { :receipts => :notification }) - current_user.mailbox.trash(:include => { :receipts => :notification })

  # end

  # mailboxer code starts -----------



  # to append a conversation based on the id
  # def conversation

  #     @conversation ||= mailbox.conversations.find(params[:id])
  #   end

  #   # fetched the current user mailbox. Provided by the gem
  # def mailbox
  #   @mailbox ||= current_user.mailbox
  # end

  # # breaks the parameters and passes on to fetch_params function to fetch
  # # a result based on the parameters passed.
  # def conversation_params(*keys)
  #     fetch_params(:conversation, *keys)
  #   end

  #   # breaks the parameters and passes on to fetch_params function to fetch
  # # a result based on the parameters passed.
  #   def message_params(*keys)
  #     fetch_params(:message, *keys)
  #   end

  #   # fetches a result based on the parameters passed.
  #   def fetch_params(key, *subkeys)
  #     params[key].instance_eval do
  #     case subkeys.size
  #     when 0 then self
  #     when 1 then self[subkeys.first]
  #     else subkeys.map{|k| self[k] }
  #     end
  #   end
  # end

  # mailboxer code ends ---------


  #--------------------------------------------------------------------------#
  # sort_review ----> "Perform sorting of reviews based on rating and date"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # +params[:sort_by]+::"date"
  # +params[:sort_by]+::"rating"
  # Params --- OUT:
  # +@user_reviews+:: returns array of reviews of reviewer
  # +@reviews_of_user+:: returns array of reviews of reviewee
  #--------------------------------------------------------------------------#
  def sort_review
    @user = User.find_by_id(params[:id])
    if params[:accepted_offer_id] and params[:sort_by]
      accepted_offer = AcceptedOffer.find(params[:accepted_offer_id])
      if params[:sort_by] == 'date'
        @user_reviews = accepted_offer.reviews.all(:order => "created_at desc")
      elsif params[:sort_by] == 'rating'
        @user_reviews = accepted_offer.reviews.all(:order => "overall_rating desc")
      end
    elsif params[:sort_by]
      if params[:sort_by] == 'date'
        @user_reviews = @user.user_reviews.all(:order => "created_at desc")
        @reviews_of_user = @user.reviews.all(:order => "created_at desc")

      elsif params[:sort_by] == 'rating'
        @user_reviews = @user.user_reviews.all(:order => "overall_rating desc")
        @reviews_of_user = @user.reviews.all(:order => "overall_rating desc")
      end
    end
  end

  def settings
    @user = current_user
  end

  def update_settings
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    redirect_to settings_user_path(params[:id])
  end

  def friends_invite
    @user = User.find_by_id(params[:id])
  end

  def update_wants_message_reminder
    if params[:id]
      if params[:id].to_i == current_user.id
        current_user.want_message_reminder = false
        current_user.save
      end
    end
    render :text => "OK"
  end

  def user_main_photo
    if params.present?
      main_image = UserPhoto.find(params[:photo_id])
      if current_user and main_image.user.id == current_user.id
        current_user.user_photos.update_all(:user_main_photo => false)
        main_image.update_attributes(:user_main_photo => true)
      end
    end
  end

  def delete_activity
    a = PublicActivity::Activity.find(params[:activity_id])
    a.deleted = true
    a.save
    respond_to do |format|
      format.js
    end
  end

  def delete_alert

  end

  def pvt_msg_tab
    if params[:id].present?
      @user = User.find_by_id(params[:id])
      @user_images = @user.user_all_image(:large)
      @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
      @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
      @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?

     end
  end

  # def edit_photo
  #   if params[:id].present?
  #     @photo = UserPhoto.find_by_id(params[:id])
  #     # if Rails.env.development?
  #     #   file_path = "public" + @photo.photo(:large).split('?')[0]
  #     #   original = "public" + @photo.photo(:edited).split('?')[0]
  #     # elsif Rails.env.staging_20? or Rails.env.production?
  #     #   file_path = @photo.photo.url(:large).split('?')[0]
  #     #   original = @photo.photo.url(:edited).split('?')[0]
  #     # end
  #     new_photo = UserPhoto.new
  #     if File.exist?(@photo.photo.path)
  #       new_photo.photo = File.open(@photo.photo.path)
  #       file_path = new_photo.photo.path(:large).split('?')[0]
  #       original = new_photo.photo.path(:edited).split('?')[0]
  #     else
  #       file_path = new_photo.photo_from_url(@photo.photo.url(:large))
  #       # render :text => '<pre>' + file_path.to_yaml and return
  #       original = new_photo.photo_from_url(@photo.photo.url(:edited))
  #     end
  #     img = Image.read(file_path).first
  #     if params[:crop_form]
  #       crop = img.crop(params[:crop_x].to_i, params[:crop_y].to_i,params[:crop_w].to_i,params[:crop_h].to_i)
  #       crop.write(file_path)
  #     else
  #       if params[:color] == "black"
  #         mono = img.quantize(256, Magick::GRAYColorspace)
  #         colorized = mono.colorize(0.30, 0.30, 0.30, '#303030')
  #         colorized.write(file_path)
  #       elsif params[:done] == "true"
  #         reset = img
  #         reset.write(original)
  #       elsif params[:close] == "true"
  #         original_img = Magick::Image.read(original).first
  #         reset = original_img
  #         reset.write(file_path)
  #       end
  #     end
  #     respond_to do |format|
  #       format.js{render :action => 'edit_photo'}
  #     end
  #   end
  # end

  def edit_photo
    if params[:id].present?
      @photo = UserPhoto.find_by_id(params[:id])
      contents = Magick::Image.read(params[:url]).first
      file = Tempfile.new(["Edited_Photo", ".jpg"])
      contents.write(file.path)
      @photo.update_attributes(:photo=>file)
    end
  end

  def active_trades
    if params[:id].present?
      @user = User.find_by_id(params[:id])
      if @user.present?
        @overall_rating = @user.overall_rating.round(1) if
           @user.overall_rating.present?
        @describe_rating = @user.describe_rating.round(1) if
          @user.describe_rating.present?

        @communication_rating = @user.communication_rating.round(1) if
          @user.communication_rating.present?

        if $redis.present?
          @recent_items_redis = $redis.smembers("recent-items:#{current_user.id}")
        else
          @recent_items_redis = nil
        end
        
        @recent_items = []
        if @recent_items_redis.present?
          unless @recent_items_redis.size == 0
            @recent_items_ids = @recent_items_redis.map { |x| x.split(":").last.to_i }
            @recent_item_objects = Item.find(@recent_items_ids)
            @recent_items = @recent_item_objects.map{ |item| {title: item.get_short_title, url: item_path(item)} }
          end
        end
      end
    end
  end

end
