class Api::V1::UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token,
  :if => Proc.new { |c| c.request.format == 'application/json' }

  before_filter :authenticate_user_from_token!, :except => [:index, :show]
  respond_to :json

  #--------------------------------------------------------------------------#
  # show ----> "User's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  #--------------------------------------------------------------------------#
  def show
# debuggre
    if params[:id].present?
      @user = User.find_by_id(params[:id])
      if @user.present?
        # @overall_rating = @user.overall_rating.round(1) if
        #   @user.overall_rating.present?
        @overall_rating = 4.9
        @describe_rating = @user.describe_rating.round(1) if
          @user.describe_rating.present?

        @communication_rating = @user.communication_rating.round(1) if
          @user.communication_rating.present?
      end
    end
  end


  #--------------------------------------------------------------------------#
  # wants_tab ----> "Wants tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  # +@wanted_items+:: returns array of user's wants
  #--------------------------------------------------------------------------#
  def wants
    @user = User.find_by_id(params[:id])
    @wanted_items = @user.want_items
  end


  #--------------------------------------------------------------------------#
  # haves_tab ----> "Haves tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  # +@have_items+:: returns array of user's haves
  #--------------------------------------------------------------------------#
  def haves
    @user = User.find_by_id(params[:id])
    @have_items = @user.have_items
  end


  #--------------------------------------------------------------------------#
  # likes_tab ----> "Likes tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  # +@liked_items+:: returns array of user's likes
  #--------------------------------------------------------------------------#
  def likes
    @user = User.find_by_id(params[:id])
    @liked_items = @user.like_items
  end


  #--------------------------------------------------------------------------#
  # past_trades_tab ----> "Past Trades tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  #--------------------------------------------------------------------------#
  def past_trades
    @user = User.find_by_id(params[:id])
    @past_trades = @user.past_trades
  end


  #--------------------------------------------------------------------------#
  # reviews_tab ----> "Reviews tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  # +@user+:: returns user based on params[:id]
  #--------------------------------------------------------------------------#
  def reviews
    @user = User.find_by_id(params[:id])
    @unreview_trades = @user.unreview_trades
    @user_reviews = @user.user_reviews.all(:order => "overall_rating desc")
    @reviews_of_user = @user.reviews.all(:order => "overall_rating desc")
  end


  #--------------------------------------------------------------------------#
  # following_tab ----> "Following tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  # +@followed_items+:: returns array of following users followed by @user
  #--------------------------------------------------------------------------#
  def following_items
    @user = User.find_by_id(params[:id])
    @followed_items = @user.followed_items
  end

  #--------------------------------------------------------------------------#
  # following_tab ----> "Following tab on user's Profile page"
  # Params --- IN:
  # +params[:id]+::"user_id"
  # Params --- OUT:
  # +@followed_items+:: returns array of following users followed by @user
  #--------------------------------------------------------------------------#
  def followed_users
    @user = User.find_by_id(params[:id])
    @users = @user.followed_users
  end

  def followers
    @user = User.find_by_id(params[:id])
    @users = @user.followers
  end

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

    render :status => 200,
           :json => { :success => true,
                      :info => "follow/unfollow success",
                      :data => {} }

  end

  def device
    @user = User.find_by_id(params[:id])
    if current_user.id == params[:id].to_i and params[:device_type].is_a? Integer
      NotificationDevice.find_or_create(:user_id => @user.id, :device_id => params[:device_id], :device_type => params[:device_type])
      success = true
      info = "device id saved"
    else 
      success = false
      info = "make sure device type is an integer and that user id is correct"
    end

    render :status => 200,
           :json => { :success => success,
                      :info => info,
                      :data => {} }
  end

  def search
    radius = params[:radius]
    search = params[:search]
    page_size = params[:page_size] ||= 10
    page = params[:page]
    sort = params[:sort]
    @user_ll = []
    unless params[:lat].nil? || params[:lng].nil?
      @user_ll << params[:lat]
      @user_ll << params[:lng]
    end

    @users = User.user_search(search, sort, page, @user_ll, radius, page_size)
    @users.nil? ? @users = [] : @users &&= @users.results
  end

end
