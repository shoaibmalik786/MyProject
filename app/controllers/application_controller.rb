class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery

  before_filter :set_cache_buster
  before_filter :get_tracking_params

  after_filter :store_location
  helper_method :item_saved

  def store_location
    # store last url - this is needed for post-login
    # redirect to whatever the user last visited.
    if (request.fullpath != "/users/sign_in" && \
        request.fullpath != "/users/sign_up" && \
        request.fullpath != "/users/password" && \
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || home_path
  end

  def authenticate_active_admin_user!
    authenticate_user!
    unless current_user.superadmin?
      flash[:alert] = "Unauthorized Access!"
      redirect_to root_path
    end
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 2013 00:00:00 GMT"
  end

  def default_url_options(opts={})
    if Rails.env.development?
      opts.merge({:host => 'localhost' })
    elsif Rails.env.staging?
      opts.merge({:host => 'tradeya.addvalsolutions.com' })
    elsif Rails.env.staging_20?
      opts.merge({:host => 'tradeya2.addvalsolutions.com' })
    else
      opts.merge({:host => 'www.tradeya.com' })
    end
  end
  # FIXME: add definition comments here

  # TODO: Add comments
  def current_location
    if session[:user_ll].blank?
      location = nil
      if current_user.present?
        if current_user.lat.present? and current_user.lng.present?
          session[:user_ll] = [current_user.lat,current_user.lng]
          session[:user_location] = "#{current_user.city}, #{current_user.state}"
          return
        elsif current_user.zip.present?
          location = current_user.zip
        elsif current_user.city.present?
          location = "#{current_user.city}, #{current_user.state}"
        end
      end
      location = request.remote_ip if location.blank?
      begin
        geo_location = Geocoder.search(location).first unless location == "127.0.0.1"
      rescue SyntaxError => e
        puts 'Unable to parse Address for IP: ' + request.remote_ip.to_s
      end
      if geo_location.present? and geo_location.coordinates.present? and
          (geo_location.country_code == "US" or geo_location.country_code == "USA" or geo_location.country_code == "Canada" or geo_location.country_code == "CA")
        session[:user_ll] = geo_location.coordinates
        session[:user_location] = "#{geo_location.city}, #{geo_location.state_code}"
        if current_user and (current_user.lat.blank? or current_user.lng.blank?)
          current_user.state = geo_location.state_code
          current_user.city = geo_location.city
          current_user.lat = geo_location.latitude
          current_user.lng = geo_location.longitude
          current_user.zip = geo_location.postal_code
          current_user.save
        end
        return
      else
        session[:user_ll] = [34.0126379,-118.495155]
        session[:user_location] = "Santa Monica, CA"
        if current_user and (current_user.lat.blank? or current_user.lng.blank?)
          current_user.state = "CA"
          current_user.city = "Santa Monica"
          current_user.lat = "34.0126379"
          current_user.lng = "-118.495155"
          current_user.zip = "90405"
          current_user.save
        end
      end
    end
  end

  def fb_mutual_friends(u1, u2)
    mf = []
    begin
      a1 = u1.authentication('facebook')
      a2 = u2.authentication('facebook')

      if not a1.nil? and not a2.nil? and not session[:facebook_token].nil?
        u1_fs = HTTParty.get('https://graph.facebook.com/' + a1.uid + '/friends?access_token=' + a1.access_token + '&limit=5000')
        u2_fs = HTTParty.get('https://graph.facebook.com/' + a2.uid + '/friends?access_token=' + a2.access_token + '&limit=5000')

        d1 = JSON.parse(u1_fs.body)["data"]
        d2 = JSON.parse(u2_fs.body)["data"]

        d1.each do |f1|
          d2.each do |f2|
            if f1["id"] == f2["id"]
              arr = Hash.new
              arr["image"] = User.user_image_by_uid(f1["id"])
              arr["name"] = f1["name"]
              arr["uid"] = f1["id"]
              mf.push(arr)
              break
            end
          end
        end
      end
    rescue
      return []
    end

    fb_firends_location(u1, mf)
    linkedin_mutual_friends(u1, u2, mf)
    return mf
  end

  def fb_firends_location(u, mf)
    a = u.authentication('facebook')

    begin
      uids = ""
      mf.each do |h|
        uids = uids + (uids.length == 0 ? "" : ",") + "'" + h["uid"] + "'"
      end

      addrs = []
      if uids.length > 0
        q = 'SELECT uid, current_location FROM user WHERE uid IN(' + uids + ')'
        q = URI.encode(q)
        addrs = HTTParty.get('https://graph.facebook.com/fql?q=' + q + '&access_token=' + a.access_token + '&limit=5000')
      end

      addrs = JSON.parse(addrs.body)["data"]

      mf.each do |h|
        addrs.each do |addr|
          if addr["uid"].to_s == h["uid"].to_s
            cl = addr["current_location"]
            if not cl.nil?
              h["location"] = (cl["city"].blank? ? "" : cl["city"].gsub(", ", " ").gsub(",", " ")) + (cl["state"].blank? ? "" : (cl["city"].blank? ? cl["state"] : " " + cl["state"])) + (cl["zip"].blank? ? "" : ((cl["city"].blank? and cl["state"].blank?) ? cl["zip"] : " " + cl["zip"]))
              if h["location"].length == 0 then h[:location] = cl["name"] end
            end
            break
          end
        end

        if h["location"].nil? or h["location"].length == 0
          usr = User.user_by_uid(h["uid"])
          if usr
            h["location"] = usr.location
          end
        end
      end
    rescue
    end

    return mf
  end

  def fb_friends_count(u)
    c = 0
    begin
      a = u.authentication('facebook')

      if not a.nil? and not a.access_token.blank?
        q = 'SELECT uid, friend_count FROM user WHERE uid=' + a.uid
        q = URI.encode(q)
        addrs = HTTParty.get('https://graph.facebook.com/fql?q=' + q + '&access_token=' + a.access_token + '&limit=5000')
        d = JSON.parse(addrs.body)["data"]
        if not d.nil? and d.count > 0 then c = d[0]["friend_count"] end
      end
    rescue
      c = 0
    end

    return c
  end

  def twitter_mutual_friends(u1, u2)
    mf = []
    mt_ids=""
    begin
      a1 = u1.authentication('twitter')
      a2 = u2.authentication('twitter')

      if not a1.nil? and not a2.nil?
        u1_fs = HTTParty.get('https://api.twitter.com/1/friends/ids.json?user_id=' + a1.uid.to_s)
        u2_fs = HTTParty.get('https://api.twitter.com/1/friends/ids.json?user_id=' + a2.uid.to_s)
        d1 = JSON.parse(u1_fs.body)["ids"]
        d2 = JSON.parse(u2_fs.body)["ids"]

        d1.each do |f|
          if d2.include?(f)
            mt_ids = mt_ids.blank? ? "#{d2[d2.index(f)]}" : "#{mt_ids},#{d2[d2.index(f)]}"
          end
        end

        if !mt_ids.blank?
          details = HTTParty.get('https://api.twitter.com/1/users/lookup.json?user_id=' + mt_ids)
          friends = JSON.parse(details.body)
          friends.each do |f|
            arr = Hash.new
            arr["image"] = f["profile_image_url"]
            arr["name"] = f["name"]
            arr["uid"] = f["id_str"]
            arr["location"] = f["location"]
            mf.push(arr)
          end
        end
      end

    rescue
      return []
    end

    return mf
  end

  def twitter_friends_count(u)
    c = 0
    begin
      a = u.authentication('twitter')

      if not a.nil?
        details = HTTParty.get('https://api.twitter.com/1/users/lookup.json?user_id=' + a.uid)
        d = JSON.parse(details.body)
        if not d.nil? and d.count > 0 then c = d[0]["friends_count"] end
      end
    rescue
      c = 0
    end

    return c
  end

  def linkedin_mutual_friends(u1, u2, mf)
    begin
      a1 = u1.authentication('linkedin')
      a2 = u2.authentication('linkedin')

      if not a1.nil? and not a2.nil?
        client = LinkedIn::Client.new(LINKEDIN_CONSUMER_KEY, LINKEDIN_CONSUMER_SECRET, LINKEDIN_CONFIGURATION)
        client.authorize_from_access(a1.access_token, a1.access_secret)
        cons1 = client.connections

        client = LinkedIn::Client.new(LINKEDIN_CONSUMER_KEY, LINKEDIN_CONSUMER_SECRET, LINKEDIN_CONFIGURATION)
        client.authorize_from_access(a2.access_token, a2.access_secret)
        cons2 = client.connections

        cons1.all.each do |c1|
          cons2.all.each do |c2|
            if c1.id == c2.id
              arr = Hash.new
              arr["image"] = (c1.picture_url.nil? ? "https://s3.amazonaws.com/tradeya_prod/tradeya/images/TY_DefaultUser_sm.gif" : c1.picture_url)
              arr["name"] = c1.first_name + ((c1.last_name.nil? or c1.last_name.length == 0) ? "" : " ") + c1.last_name
              arr["uid"] = c1.id
              arr["location"] = (c1.location.nil? ? "" : c1.location.name)
              mf.push(arr)
              break
            end
          end
        end
      end
    rescue
    end

    return mf
  end

  def linkedin_friends_count(u)
    c = 0
    begin
      a = u.authentication('linkedin')

      client = LinkedIn::Client.new(LINKEDIN_CONSUMER_KEY, LINKEDIN_CONSUMER_SECRET, LINKEDIN_CONFIGURATION)
      client.authorize_from_access(a.access_token, a.access_secret)
      cons = client.connections
      c = cons.total
    rescue
      c = 0
    end

    return c
  end

  def require_user
    unless current_user
      redirect_to root_url
      return false
    end
  end

  def check_route
    chk_item_share_url = false
    chk_unsubscribe_url = false
    if current_user.present? and not session[:user_visited_hello].present? then session[:user_visited_hello] = true end
    if not request.fullpath.index('/unsubscribe_mail').nil? then chk_unsubscribe_url = true end
    if not request.fullpath.index('/items/').nil? and params[:id].present? and params[:id].split('-').length > 1 then chk_item_share_url = true end

    if session[:user_visited_hello].nil? and (not request.fullpath.index('/services/').nil? or not request.fullpath.index('/goods/').nil? or not request.fullpath.index('/items').nil? or not request.fullpath.index('/home').nil? or not request.fullpath.index('/browse').nil? or request.fullpath == '/update_user_categories' or request.fullpath == '/execute_matching' or not request.fullpath.index('/users/confirmation?confirmation_token=').nil? or not request.fullpath.index('/submit_user_review/').nil? or not request.fullpath.index('/contest').nil?) then session[:user_visited_hello] = true end

    if ((not request.referer.nil? and not request.referer.index('/hello').nil?) or (request.referer.nil? and not request.fullpath.index('/auth/facebook/callback').nil?) or (not session[:user_visited_hello].nil?) or chk_unsubscribe_url)
      session[:user_visited_hello] = true
    elsif (((request.referer.nil? and session[:user_visited_hello].nil?) or (session[:user_visited_hello].nil? and request.referer.index('/hello').nil?)) and (request.fullpath.index('/auth/failure').nil?) and not chk_item_share_url and not chk_unsubscribe_url and (request.fullpath.index('/modals').nil?))
      session[:show_hello] = true
      session[:user_visited_hello] = true
      redirect_to "/"
      # red_url = ab_test('LandingPage', "/", "/items")
      # red_url = APP_PROP[:landing_page]
      # APP_PROP[:landing_page] = ((APP_PROP[:landing_page] == "/") ? "/items" : "/")
      # # finished("LandingPage")
      # redirect_to red_url

    end
  end

  def clear_session_of_guest
    if session[:guest_offer_as_tod].nil?
      session[:guest_user_id] = nil
      session[:is_guest_user] = nil
    end
  end


  def after_invite_path_for(user)
    invite_user_path(current_user)
  end

  # redirection after accepting invitation from mail and setting pwd
  def after_accept_path_for(user)
    items_path
  end

  def item_saved(item_id)
    return Item.find(item_id)
  end

  # def log_request
  #   # ssl = SigninSignupLog.new
  #   # begin
  #   #   ssl.request_url = request.env['REQUEST_URI']
  #   #   ssl.request_referer = request.referer
  #   #   ssl.req_method = request.request_method
  #   #   ssl.remote_ip = request.remote_ip
  #   #   ssl.current_user = ((current_user.nil?) ? "" : current_user.email)
  #   #   ssl.current_user_id = ((current_user.nil?) ? 0 : current_user.id)
  #   #   ssl.cur_authenticity_token = form_authenticity_token
  #   #   ssl.req_authenticity_token = params[:authenticity_token]

  #   #   if "/users/sign_in" == request.fullpath
  #   #     if params[:user].present? then ssl.req_email = params[:user][:email] end
  #   #     ssl.status = "try"
  #   #     ssl.desc = "try to login."
  #   #   elsif "/users" == request.fullpath
  #   #     if params[:user].present? then ssl.req_email = params[:user][:email] end
  #   #     ssl.status = "try"
  #   #     ssl.desc = "try to signup."
  #   #   end

  #   #   ssl.session_id = request.session_options[:id]
  #   #   ssl.user_agent = request.env['HTTP_USER_AGENT']
  #   #   ssl.params = params.to_json
  #   #   ssl.session = session.to_json
  #   #   ssl.save
  #   #   session[:log_id] = ssl.id
  #   # rescue StandardError => e
  #   #   ssl.status = "failed"
  #   #   ssl.desc = "log request failed. " + e.message
  #   #   ssl.save
  #   #   session[:log_id] = ssl.id
  #   # end

  # end

  # def check_user_profile
  #   # if current_user
  #   #   profile_status = current_user.user_profile_status
  #   #   if profile_status == 3
  #   #     return true
  #   #   else
  #   #     redirect_to profile_url + '?step='+(profile_status+1).to_s
  #   #   end
  #   # end
  # end

  def get_tracking_params
    session[:track] = {} if session[:track].nil?
    session[:track][:sbx_code] = params[:tid] if params[:tid].present?
    session[:track][:utm_campaign] = params[:utm_campaign] if params[:utm_campaign].present?
    session[:track][:utm_source] = params[:utm_source] if params[:utm_source].present?    
    session[:track][:utm_medium] = params[:utm_medium] if params[:utm_medium].present?
    session[:track][:utm_content] = params[:utm_content] if params[:utm_content].present?
    session[:track][:utm_term] = params[:utm_term] if params[:utm_term].present?
  end

  def register_tracking_params
    if current_user    
      current_user.update_tracking_info()
    end
  end

  private

  # call this method for token authentication
  def authenticate_user_from_token!
    # Set the authentication params if not already present
    if user_token = params[:user_token].blank? && request.headers["X-User-Token"]
      params[:user_token] = user_token
    end
    if user_email = params[:user_email].blank? && request.headers["X-User-Email"]
      params[:user_email] = user_email
    end
    
    user_email = params[:user_email].presence
    user = user_email && User.find_by_email(user_email)
    
    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      # Notice we are passing store false, so the user is not
      # actually stored in the session and a token is needed
      # for every request. If you want the token to work as a
      # sign in token, you can simply remove store: false.
      sign_in user, store: false
    end
  end
  
end
