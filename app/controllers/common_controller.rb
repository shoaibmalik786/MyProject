class CommonController < ApplicationController
  before_filter :current_location, :except => [:privacy_policy]
  cache_sweeper :category_sweeper, :only => [:clear_cache]
  cache_sweeper :user_sweeper, :only => [:update_profile]
  cache_sweeper :user_photo_sweeper, :only => [:edit_user_image]
  caches_action :howthisworks, :layout => false
  caches_action :modals, :cache_path => Proc.new { |c| c.params[:signed_in] = (not current_user.nil?); c.params}, if: lambda { |c| c.params[:tradeya_carousel_n_r_panel].present? }

  require 'twitpic'
  require 'httparty'
  require 'open-uri'
  @@TOKEN_SECRET = ""

  def after_sign_up
    @user_signup = session["signup_user"]
    session["signup_user"] = nil

    @msg = nil
    if @user_signup and @user_signup.errors.any?
      @msg = "<ul>"
      @user_signup.errors.full_messages.each do |m|
        if @msg.index(m).nil?
          @msg = @msg + "<li>#{m}</li>"
        end
      end
    end

    if not session["signup_user_msg"].nil?
      @msg = (@msg.nil? ? "<ul>" : @msg)
      @msg = @msg + "<li>#{session["signup_user_msg"]}</li>"
      session["signup_user_msg"] = nil
    end

    if (@user_signup and @user_signup.errors.any?) or not session["signup_user_msg"].nil?
      @msg = @msg + "</ul>"
    end

    render :layout => false
  end

  def thanks

  end

  def after_sign_up_guest
    render :layout => false
  end

  def after_update_guest
    render :layout => false
  end

  def is_signed_in
    if current_user or session[:is_guest_user]
      render :text => 'true'
    else
      render :text => 'false'
    end
  end

  def is_pub
    item = Item.find(params[:id])
    if item and (item.user_id == current_user.id)
      render :text => 'true'
    else
      render :text => 'false'
    end
  end

  def sign_in_success
    if current_user
      if !current_user.active
        current_user.active = true
        current_user.save
      end
      # user_profile_status = current_user.user_profile_status.to_s
      user_profile_status = ((current_user.showed_onboarding) ? '3' : '0')
      pub = current_user.pub?
      if session[:review_token]
        render :text => 'true:token:' + session[:review_token] + ':profile:' + user_profile_status
        session[:review_token] = nil
      elsif pub
        session[:pub] = pub
        render :text => 'true:pub:' + current_user.user_tradeya_ids + ':profile:' + user_profile_status
      else
        session[:pub] = nil
        render :text => 'true:profile:' + user_profile_status
      end
    else
      session[:pub] = nil
      render :text => 'false'
    end
  end

  def facebook_sign_in_success
    if current_user && !current_user.active
      current_user.active = true
      current_user.save
    end
    # render :layout => false
  end

  # def sign_out_success
  #   render :text => 'true'
  # end

  def failure
    render :layout => false
  end

  def failure_network
    render :layout => false
  end

  def modals
    if params[:your_offer_form]
      @item = Item.find(params[:item_id])
      @item_photo = ItemPhoto.new
      @item_video = ItemVideo.new
      @offer = Item.new
      @status = @item.item_status
      @pub = false
      @offerer = false

      if current_user
        @pub = current_user.pub?
        @offerer = current_user.offerer?(@item.id)
      end
    elsif params[:sign_in_block]
      if params[:st_pg] then @st_pg = true end
    elsif params[:refresh_promote]
      @item = Item.find(params[:item_id])

      @pub = false
      if current_user
        @pub = current_user.pub?
      end
      @status = @item.item_status
    elsif params[:offer_section]
      @item = Item.find(params[:item_id])
      @trades = @item.other_trades
      @accepted_offers = @item.accepted_trades

      @status = @item.item_status
      #Generating Reviews about offerers
      @offererReviews = Array.new
      @trades.each do |trade|
        offerer = trade.offer.user_id
        @offererReviews.push(User.get_user_reviews(offerer))
      end
      #Generating Reviews about accepted offerers
      @accepted_offererReviews = Array.new
      @accepted_offers.each do |trade|
        offerer = trade.offer.user_id
        @accepted_offererReviews.push(User.get_user_reviews(offerer))
      end

      @pub = false
      @offerer = false
      if current_user
        @pub = current_user.pub?(@item)
        @offerer = current_user.offerer?(@item.id)
      end

      #Generating mutual connections
      @mc = Hash.new  #mutual connections
      @amc = Hash.new  #accepted mutual connections
      if @pub
        @trades.each do |trade|
          if !@mc[trade.offer.user.id] or @mc[trade.offer.user.id].nil?
            @mc[trade.offer.user.id] = MutualFriend.get_mutual_friends_details(current_user.id,trade.offer.user.id)
            # connections = fb_mutual_friends(current_user,trade.offer.user)
            # connections.concat(twitter_mutual_friends(current_user,trade.offer.user))
            # @mc[trade.offer.user.id] = connections
          end
        end
        @accepted_offers.each do |trade|
          if !@amc[trade.offer.user.id] or @amc[trade.offer.user.id].nil?
            @amc[trade.offer.user.id] = MutualFriend.get_mutual_friends_details(current_user.id,trade.offer.user.id)
            # connections = fb_mutual_friends(current_user,trade.offer.user)
            # connections.concat(twitter_mutual_friends(current_user,trade.offer.user))
            # @amc[trade.offer.user.id] = connections
          end
        end
      end
    elsif params[:comments_section]
      @item = Item.find(params[:item_id])
      @comments = Comment.item_comments(@item.id)
      @status = @item.item_status
    elsif params[:mutual_con]
      @item = Item.find(params[:item_id])
      @offerer_mc = [] #offerer or potential offerer's mutual connection with item owner
      @pub = false
      if current_user
        @pub = current_user.pub?(@item)
      end
      if !@pub and current_user
        @offerer_mc = MutualFriend.get_mutual_friends_details(current_user.id,@item.user.id)
        # connections = fb_mutual_friends(current_user,@item.user)
        # connections.concat(twitter_mutual_friends(current_user,@item.user))
      end
    elsif params[:tradeya_carousel_n_r_panel]
      @tradeyas = Item.carousel_navigation(params[:cat_id])
    elsif params[:promotenow_modal]
      @item = Item.find(params[:item_id])
    elsif params[:pst_ofr_and_trd]
      @past_offer_tradeyas = []
      if current_user
        @past_offer_tradeyas = Item.find(:all, :select => "id,title,tod,created_at", :conditions => ["user_id = ? AND status != 'DELETED'", current_user.id], :order => 'created_at')
      end
    elsif params[:profile_image_section]
      @user = current_user if current_user.present?
      @user_images = @user.user_all_image(:medium)
    end
    render :layout => false
  end

  def sign_up_model
    render :layout => false
  end

  def offer_form
    render :layout => false
  end

  def contact
    copy2me = (params[:copy2me] == 'true')
    i = Item.find(params[:item_id])
    # EventNotificationMailer.contact(current_user, i, params[:re], params[:msg]).deliver
    # if copy2me then EventNotificationMailer.contact_pub_copy(current_user, i,params[:msg]).deliver end
    EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_CONTACT, i.user.id, {:item_id => i.id, :user_id => current_user.id, :subject => params[:re], :msg => params[:msg], :trade_id => params[:trade_id].to_i})
    if copy2me then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_CONTACT_PUB_COPY, current_user.id, {:item_id => i.id, :msg => params[:msg], :trade_id => params[:trade_id].to_i}) end
    render :text => "sent"
  end

  def password_reset
    if !session["user"].nil?
      @user_resetpwd = session["user"]
      session["user"] = nil
    end
    if (@user_resetpwd and @user_resetpwd.errors.any?) # or (@user_resetpwd and @user_resetpwd.authentications.length > 0)
      session["user"] = @user_resetpwd
      redirect_to new_user_password_url
    end
  end

  def twitter_share_login
    if session[:twitter_access_token].nil?
      method = "POST"
      secret = TWITTER_CONSUMER_SECRET
      key = TWITTER_CONSUMER_KEY
      @base_uri = "https://api.twitter.com/oauth/request_token"
      @params    = {
                    'oauth_callback'         => encode("#{root_url}twitter_share?item_id=#{params[:item_id]}"),
                    'oauth_consumer_key'     => TWITTER_CONSUMER_KEY,
                    'oauth_nonce'            => generate_nonce,
                    'oauth_signature_method' => "HMAC-SHA1",
                    'oauth_timestamp'        => Time.new.to_i.to_s,
                    'oauth_version'          => "1.0"
                   }
      @request_signature = (method + '&' + encode(@base_uri) + '&' + @params.sort.collect{ |h| "#{encode(h.first)}%3D#{encode(h.last)}" }.join("%26"))
      digest = OpenSSL::Digest::Digest.new( 'sha1' )
      @encoded = ActiveSupport::Base64.encode64(OpenSSL::HMAC.digest(digest, secret, @request_signature)).chomp.gsub(/\n/, "")
      @headers = {
                  'oauth_nonce'             => @params['oauth_nonce'],
                  'oauth_callback'          => @params['oauth_callback'],
                  'oauth_signature_method'  => 'HMAC-SHA1',
                  'oauth_timestamp'         => @params['oauth_timestamp'],
                  'oauth_consumer_key'      => @params['oauth_consumer_key'],
                  'oauth_signature'         => encode(@encoded),
                  'oauth_version'           => '1.0'
                 }
      @s = "OAuth " + @headers.collect{|h| "#{h.first}='#{h.last}'"}.join(", ")
      @s.gsub!("'",'"')

      @res = HTTParty.post(@base_uri,:headers => {"Authorization" => @s})
      if @res.headers['status'] == "200 OK"
        @oauth_token = @res.parsed_response.split('=')[1].split('&')[0]
        @oauth_token_secret = @res.parsed_response.split('=')[2].split('&')[0]
        @@TOKEN_SECRET = @oauth_token_secret
        @callback_confirm = @res.parsed_response.split('=')[3]
        url = "https://api.twitter.com/oauth/authorize?oauth_token=" + @oauth_token
        if session[:callback] != request.referer
          session[:callback] = request.referer
        end
        redirect_to url
      else
        @msg = "Error occurred during authentication!"
        render :layout => false
      end
    else
      redirect_to twitter_share_url + '?item_id=' + params[:item_id]
    end
  end

  def twitter_share
    callback = session[:callback]
    session[:callback] = nil
    if params[:denied]
      flash[:error] = "You must authorize this site for login"
      redirect_to callback
    else
      if params[:oauth_verifier] and params[:oauth_token]
        @oauth_verifier = params[:oauth_verifier]
        @oauth_token = params[:oauth_token]
        method = "POST"
        secret = TWITTER_CONSUMER_SECRET
        base_uri = "https://api.twitter.com/oauth/access_token"
        @params = {
                   'oauth_consumer_key'     => "3c0dklnpUOLPP9WOUyRVAg",
                   'oauth_nonce'            => generate_nonce,
                   'oauth_signature_method' => "HMAC-SHA1",
                   'oauth_token'            => @oauth_token,
                   'oauth_timestamp'        => Time.new.to_i.to_s,
                   'oauth_verifier'         => @oauth_verifier,
                   'oauth_version'          => "1.0"
                  }
        @request_signature = (method + '&' + encode(base_uri) + '&' + @params.sort.collect{ |h| "#{encode(h.first)}%3D#{encode(h.last)}" }.join("%26"))
        digest = OpenSSL::Digest::Digest.new( 'sha1' )
        @encoded = ActiveSupport::Base64.encode64(OpenSSL::HMAC.digest(digest, secret + @@TOKEN_SECRET, @request_signature)).chomp.gsub(/\n/, "")
        @headers = {
                    'oauth_nonce'             => @params['oauth_nonce'],
                    'oauth_signature_method'  => 'HMAC-SHA1',
                    'oauth_timestamp'         => @params['oauth_timestamp'],
                    'oauth_consumer_key'      => @params['oauth_consumer_key'],
                    'oauth_token'             => @oauth_token,
                    'oauth_verifier'          => @oauth_verifier,
                    'oauth_signature'         => encode(@encoded),
                    'oauth_version'           => '1.0'
                   }
        @s = "OAuth " + @headers.collect{|h| "#{h.first}='#{h.last}'"}.join(", ")
        @s.gsub!("'",'"')
        @res = HTTParty.post(base_uri,:headers => {"Authorization" => @s})

        access_token = @res.parsed_response.split('=')[1].split('&')[0]
        access_token_secret = @res.parsed_response.split('=')[2].split('&')[0]

        session[:twitter_access_token] = access_token
        session[:twitter_access_token_secret] = access_token_secret
      end

      twitpic = TwitPic::Client.new
      twitpic.configure do |conf|
        conf.api_key = TWIT_PIC_API_KEY
        conf.consumer_key = TWITTER_CONSUMER_KEY
        conf.consumer_secret = TWITTER_CONSUMER_SECRET_ONLY
        conf.oauth_token = session[:twitter_access_token]
        conf.oauth_secret = session[:twitter_access_token_secret]
      end

      begin
        i = Item.find(params[:item_id])
        file = nil
        msg = ""

        if params[:item_type]
          msg = 'Vote for me! I just submit to be in the Spotlight on TradeYa.com. Check it out! ' + items_url + '/' + params[:item_id]
        else
          msg = i.title
        end

        if i.photo.present?
          begin
            file = open(i.photo.path)
          rescue StandardError => e
            file = open(i.photo.url)
          end
        end

        media = twitpic.upload_and_post(file, msg)
      rescue StandardError => e
        puts "Already posted."
      end
    end
    render :layout => false
  end

  def linkedin_login
    if current_user
      user_auth = current_user.authentication("linkedin")
      # if user verification already exist in the database, get data from database and redirect
      if user_auth and user_auth.access_token and user_auth.access_secret
        session[:atoken_linkedin] = user_auth.access_token
        session[:asecret_linkedin] = user_auth.access_secret
        redirect_to linkedin_share_url + '?item_id=' + ((params[:item_id].blank?) ? '' : params[:item_id])+'&add_verification='+((params[:add_verification].blank?) ? '' : params[:add_verification])
        return
      end
      client = LinkedIn::Client.new(LINKEDIN_CONSUMER_KEY, LINKEDIN_CONSUMER_SECRET, LINKEDIN_CONFIGURATION)
      request_token = client.request_token(:oauth_callback => linkedin_share_url + '?item_id=' + ((params[:item_id].blank?) ? '' : params[:item_id])+'&add_verification='+((params[:add_verification].blank?) ? '' : params[:add_verification]))
      session[:rtoken_linkedin] = request_token.token
      session[:rsecret_linkedin] = request_token.secret
      redirect_to client.request_token.authorize_url + "&scope=r_network+r_fullprofile+r_emailaddress"
    else
      respond_to do |format|
        format.html {render "linkedin_share", :layout => false}
      end
    end
  end

  def linkedin_share
    begin
      client = LinkedIn::Client.new(LINKEDIN_CONSUMER_KEY, LINKEDIN_CONSUMER_SECRET, LINKEDIN_CONFIGURATION)
      if session[:atoken_linkedin].nil?
        pin = params[:oauth_verifier]
        atoken, asecret = client.authorize_from_request(session[:rtoken_linkedin], session[:rsecret_linkedin], pin)
        session[:atoken_linkedin] = atoken
        session[:asecret_linkedin] = asecret
        user_auth = current_user.authentication("linkedin")
        if user_auth
          user_auth.access_token = session[:atoken_linkedin]
          user_auth.access_secret = session[:asecret_linkedin]
          user_auth.save
        end
      else
        client.authorize_from_access(session[:atoken_linkedin], session[:asecret_linkedin])
      end
      # @profile = client.profile
      # @connections = client.connections
      # @msg = @connections.to_s
      if params[:item_id] and !params[:item_id].blank?
        item = Item.find(params[:item_id])
        client.add_share(:comment => "check this out",:content => {:title => item.title, :description => item.desc, "submitted-url" => item.pl_url, "submitted-image-url" => item.item_image})
      end
      if params[:add_verification] and !params[:add_verification].blank?
        uid = client.profile(:fields=>["id"]).id
        current_user.authentications.create!(:provider => 'linkedin', :uid => uid, :access_token => session[:atoken_linkedin], :access_secret => session[:asecret_linkedin])
        flash[:notice] = "Authentication successful."
        remove_session_objects
        # User.update_friend_list(current_user.id,'linkedin')
        redirect_to add_verification_success_url
        return
      end
    rescue StandardError => e
      @msg = [e.class.name, e.message].to_s
    end
    remove_session_objects
    render :layout => false
  end

  def encode( string )
    URI.escape( string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]") ).gsub('*', '%2A')
  end

  def generate_nonce(size=32)
    Base64.encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/, '')
  end

  def image_preview
    @p = nil
    name = nil
    @item = Item.find(params[:item_id]) if params[:item_id].present?
    begin
      if params[:itemimg] == 'true'
        if params[:item][:item_photo][:photo]
          if @item.present?
            params[:item][:item_photo][:photo].each do |item_image|
              @p = ItemPhoto.new({:item_id => @item.id, :photo => item_image})
            end
          else
            params[:item][:item_photo][:photo].each do |item_image|
              @p = ItemPhoto.new({:photo => item_image})
            end
          end
          @p.save!
          @isImgAutoWidth = @p.isImgAutoWidth
        elsif params[:imageURL]
          @p = ItemPhoto.new({:photo => open(URI.parse(params[:imageURL]))})
          @isImgAutoWidth = true
          @p.save
        else
          @f_f_error = true
          @path = ActionController::Base.helpers.asset_path 'default_img.png'
        end
      elsif params[:itemimg] == 'usr'
        begin
          @p = UserPhoto.new({:user_id => current_user.id,:photo => params[:user][:user_photo][:photo]})
          @p.save!
        rescue StandardError => e
          @f_f_error = true
          puts "Canceled user photo selection!"
          @path = 'https://s3.amazonaws.com/tradeya_prod/tradeya/images/TY_DefaultUser_sm.gif'
          # ActionController::Base.helpers.asset_path 'TY_DefaultUser_sm.gif'
        end
      else
        begin
          @p = UserPhoto.new({:user_id=> current_user.id,:photo => params[:item][:user_attributes][:user_photo][:photo]})
          @p.save!
          @isImgAutoWidth = @p.isImgAutoWidth
        rescue StandardError => e
          @f_f_error = true
          puts "Canceled user photo selection!"
          @path = 'https://s3.amazonaws.com/tradeya_prod/tradeya/images/TY_DefaultUser_sm.gif'
        end
      end
      if @p and !@path
        if params[:itemimg] == 'true'
          @path = @p.photo.url(:crop_large)
          if @p.photo_geometry(:original).width < 50 or @p.photo_geometry(:original).height < 50
            @f_f_error = true
          end
        else
          @path = @p.photo.url(:crop_large)
          if @p.photo_geometry(:original).width < 50 or @p.photo_geometry(:original).height < 50
            @f_f_error = true
          end
        end
      end
    rescue StandardError => e
      puts "Something Went Wrong!"
      @f_f_error = true
      @path = 'https://s3.amazonaws.com/tradeya_prod/tradeya/images/TY_DefaultUser_sm.gif'
    end
    respond_to do |format|
      format.js
      format.html {render :layout => false}
    end
    # render :layout => false
  end

  def video_preview
    @iv = nil
    file = nil
    name = nil
    @path = 'https://s3.amazonaws.com/tradeya_prod/tradeya/images/default_img.png'
    begin
      if params[:item][:item_video][:video]
        file = params[:item][:item_video][:video]
      else
        @f_f_error = true
      end

      if file
        @iv = ItemVideo.new({:video => params[:item][:item_video][:video]})
        if @iv.save
          @path = @iv.video.url
        else
          @f_f_error = true
        end
      end
    rescue StandardError => e
      @f_f_error = true
      puts "Something Went Wrong!"
    end

    render :layout => false
  end

  def publink
    redirect_to current_user.tradeya.item_url
  end

  def edit_user_profile
    if params[:profile_image]

    end
    if params[:profile_information]

    end
  end

  def edit_user_image
    if params[:user][:user_photo]
      @userImage = current_user.user_photo
      if @userImage.nil?
        # if user is authenticated through facebook, no user image is present
        if params[:user][:user_photo] and params[:user][:user_photo][:id] and params[:user][:user_photo][:id].to_i > 0
          @userImage = UserPhoto.find(params[:user][:user_photo][:id])
          @userImage.user_id = current_user.id
        else
          @userImage = UserPhoto.new
          @userImage.user_id = current_user.id
          @userImage.photo = params[:user][:photo]
        end
      else
        if params[:user][:user_photo] and params[:user][:user_photo][:id] and params[:user][:user_photo][:id].to_i > 0
          @userImage.destroy
          @userImage = UserPhoto.find(params[:user][:user_photo][:id])
          @userImage.user_id = current_user.id
        else
          @userImage.destroy
          @userImage = UserPhoto.new
          @userImage.user_id = current_user.id
          @userImage.photo = params[:user][:photo]
        end
      end
      @userImage.save
    end
    render :layout => false
  end

  def change_location
    if params[:zip].present?
      begin
        geocode_data = Geocoder.search(params[:zip]).first
        if geocode_data.present? and (geocode_data.country_code == "US" or geocode_data.country_code == "USA" or geocode_data.country_code == "Canada" or geocode_data.country_code == "CA")
          geocode_success = true
          session[:user_ll] = geocode_data.coordinates
          session[:user_location] = "#{geocode_data.city}, #{geocode_data.state_code}"
          session[:within] = params[:within]
        else
          geocode_success = false
          flash[:msg] = "Invalid City or Zip Code"
        end
      rescue
        geocode_success = false
      end
      if current_user and geocode_success
        current_user.state = geocode_data.state_code
        current_user.city = geocode_data.city
        current_user.lat = geocode_data.latitude
        current_user.lng = geocode_data.longitude
        current_user.zip = geocode_data.postal_code
        if geocode_success and current_user.save
          flash[:notice] = "User location successfully updated"
        else
          flash[:notice] = "Error in updating user location"
        end
      end
    else
      flash[:notice] = "Error in updating user location"
    end
    redirect_to request.referer
  end

  def update_profile
    # self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    if current_user
      current_user.display_name = params[:disp_name]
      current_user.zip = params[:zip_code]
      current_user.about = params[:about]

      begin
        # geocode_data = GeoKit::Geocoders::MultiGeocoder.geocode(current_user.zip)
        geocode_data = Geocoder.search(current_user.zip)
        if geocode_data.count > 0
          @geocode_success = true
          geocode_data = geocode_data[0]
        else
          @geocode_success = false
        end
        if @geocode_success and (geocode_data.country_code == "US" or geocode_data.country_code == "USA" or geocode_data.country_code == "Canada" or geocode_data.country_code == "CA")
          current_user.state = geocode_data.state_code
          current_user.city = geocode_data.city
          current_user.lat = geocode_data.latitude
          current_user.lng = geocode_data.longitude
        else
          @geocode_success = false
        end
      rescue
        puts "Failed to geocode. (#{current_user.zip})"
        @geocode_success = false
      end
      # @user_tradeyas_count = current_user.get_user_live_tradeya_count

      if @geocode_success and current_user.save
        session[:user_ll] = "#{current_user.lat},#{current_user.lng}"
        flash[:notice] = "User details successfully updated"
      else
        flash[:notice] = "Error in updating user details"
      end
      @user_tradeyas_count = current_user.get_user_live_tradeya_count
    else
      flash[:notice] = "Error in updating user details"
    end
    render :layout => false
  end

  def after_change_password
    @msg = nil
    if current_user
      if flash[:error]
        errors = flash[:error]
        @msg = "<ul>"
        errors.each do |m|
          if @msg.index(m).nil?
            @msg = @msg + "<li>#{m}</li>"
          end
        end
        @msg = @msg + "</ul>"
      end
    end
    render :layout => false
  end

  def add_verification_success
    # render :layout => false
    redirect_to edit_user_path(current_user)
  end

  def search_my_offer
    items = []
    if current_user
      tmp_offers = Item.find(:all, :select => "id,title,tod,created_at", :conditions => ["user_id = ? AND status != 'DELETED' AND title LIKE ?", current_user.id, "%#{params[:title]}%"], :order => 'title')

      tmp_offers.each do |ti|
        ti.status = " - submitted on " + ti.created_at.strftime("%d-%m-%Y") + " at " + ti.created_at.strftime("%I:%M%P")
        if ti.title.length > 50
          ti.title = ti.title[0..49] + "..."
        end
        items[items.count] = ti
      end
    end
    render :text => items.to_json
  end

  def search_my_item_wants
    items_wants = []
    if current_user
      tmp_item_wants = ItemWant.find(:all, :select => "id,title,created_at", :conditions => ["user_id = ? AND title LIKE ?", current_user.id, "%#{params[:title]}%"], :order => 'title')

      tmp_item_wants.each do |iw|
        iw.status = " - submitted on " + iw.created_at.strftime("%d-%m-%Y") + " at " + iw.created_at.strftime("%I:%M%P")
        if iw.title.length > 50
          iw.title = iw.title[0..49] + "..."
        end
        items_wants[items_wants.count] = iw
      end
    end
    render :text => items_wants.to_json
  end

  def offer_data
    item = Item.find(params[:id])
    j = JSON.parse(item.to_json)
    if item.item_videos and item.item_videos.count > 0
      j["video"] = []
      item.item_videos.each do |vi|
        vid = {}
        vid["id"] = vi.id
        vid["url"] = vi.video.url
        j["video"].push(vid)
      end
    end
    if item.item_photos and item.item_photos.count > 0
      j["photo"] = []
      item.item_photos.each do |ph|
        pho = {}
        pho["id"] = ph.id
        pho["url"] = ph.photo("medium")
        j["photo"].push(pho)
      end
    end
    # if item.item_videos and item.item_videos.count > 0
    #   j["video"] = {}
    #   j["video"]["url"] = item.item_videos[0].video.url
    #   j["video"]["file_name"] = item.item_videos[0].video_file_name
    # else
    #   j["photo"] = {}
    #   if item.item_photos.count == 0 or item.item_photos[0].nil?
    #     j["photo"]["url"] = "https://s3.amazonaws.com/tradeya_prod/tradeya/images/default_img.png"
    #     j["photo"]["file_name"] = ""
    #   else
    #     j["photo"]["url"] = item.item_image(:large)
    #     j["photo"]["file_name"] = item.item_photos[0].photo_file_name
    #   end
    # end
    render :text => j.to_json
  end

  def item_want_data
    item_want = ItemWant.find(params[:id])
    j = JSON.parse(item_want.to_json)
    render :text => j.to_json
  end

  def rotate_video
    iv = ItemVideo.find(params[:id])
    f = iv.video.to_file
    if f.path.index('.flv').nil?
      ch_file_name = f.path.gsub(f.original_filename, '') + params[:direction] + '_' + iv.video_file_name.split('.')[0] + '.flv'
      com = "mencoder " + f.path + " -vf rotate=" + params[:direction] + " -o '" + ch_file_name + "' -of lavf -oac pcm -ovc lavc -lavcopts 'vcodec=flv:vbitrate=500:mbd=2:mv0:trell:v4mv:cbp:last_pred=3'"
    else
      ch_file_name = f.path.gsub(f.original_filename, '') + params[:direction] + '_' + iv.video_file_name.split('.')[0] + '.flv'
      com = "mencoder " + f.path + " -vf rotate=" + params[:direction] + " -o " + ch_file_name + " -of lavf -oac pcm -ovc lavc -lavcopts vcodec=flv"
    end

    r = system(com)
    iv.video_from_url(open(ch_file_name))
    iv.save

    render :text => URI.encode(iv.video.url.gsub('public/', '/'))
  end

  def unsubscribe_mail
    if current_user
      redirect_to edit_settings_url
      return
    else
      redirect_to root_url + "?show_login=true&unsubscribe=true"
      return
    end
  end

  def dead_link
    render :nothing => true
  end

  def update_auth_token
    respond_to do |format|
      format.js
    end
  end

  def clear_all_cache
    expire_fragment('*')

    render :text => 'cleared'
  end

  def clear_cache
    Category.first.save
    render :text => 'cleared'
  end

  def getUserData
    if params[:guest_sign_up].present?
      if current_user
        @itemUser = current_user
      elsif params[:guest_token].present?
        @itemUser = User.find_by_guest_user_token(params[:guest_token])
      end
    elsif params[:id]
      @itemUser = User.find(params[:id])
    end
    respond_to do |format|
      format.js
    end
  end

  def hello_modal_timer
    if params[:stop] and params[:stop].present?
      # commented for quiz
      # finished("hello_split")
      session[:hello_modal_timer] = "ok"
      render :text => session[:hello_modal_timer]
    elsif params[:reset] or ((session[:hello_modal_timer].blank? or ( session[:hello_modal_timer] != "ok" and session[:hello_modal_timer].class != Array))) #and (current_user.nil? or current_user.is_guest_user))
      # commented for quiz
      # split = ab_test("hello_split","1","2")
      split = "1"
      session[:hello_modal_timer] = [Time.zone.now + 90.seconds,split]
      # session[:hello_modal_timer] = [Time.zone.now + 10.seconds,split]
      render :text => 90.seconds.to_s + "," + split
      # render :text => 10.seconds.to_s + "," + split
    elsif session[:hello_modal_timer].present? and session[:hello_modal_timer] != "ok"
      split = session[:hello_modal_timer][1]
      render :text => (session[:hello_modal_timer][0] - Time.zone.now).to_i.to_s + "," + split
    else
      session[:hello_modal_timer] = "ok"
      render :text => session[:hello_modal_timer]
    end
  end

  def privacy_policy

    respond_to do |format|
      format.html # privacy_policy.html.erb
    end

  end

  # def request_info
  #   if params.present?
  #     item = Item.find(params[:id])
  #     EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_REQUEST_INFO, item.user.id, {:user_id => current_user.id, :item_id => item.id})
  #     RequestInfoItem.create(:item_id => params[:id],:user_id => current_user.id )
  #   end
  # end

  def delete_item_photo
    if params[:photo_id].present?
      item_image = ItemPhoto.find(params[:photo_id])
      @item = item_image.item
      if item_image.present?
        item_image.destroy
      end
      respond_to do |format|
        format.js
      end
    end
  end

  def delete_user_photo
    if params[:user_photo_id].present?
      image_data = UserPhoto.find_by_id_and_user_id(params[:user_photo_id],current_user.id)
      image_data.destroy
      respond_to do |format|
        format.js
      end
    end
  end

  def twitter_failure
    redirect_to root_url
  end

  private
  def remove_session_objects
    # remove session objects
    session[:atoken_linkedin] = nil
    session[:asecret_linkedin] = nil
    session[:rtoken_linkedin] = nil
    session[:rsecret_linkedin] = nil
  end

end
