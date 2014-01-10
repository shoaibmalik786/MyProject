class AuthenticationsController < ApplicationController
  before_filter :current_location

  # GET /authentications
  # GET /authentications.json
  # TODO: remove this method for normal users
  def index
    @authentications = current_user.authentications.all if current_user

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @authentications }
    end
  end

  # GET /authentications/1
  # GET /authentications/1.json
  def show
    @authentication = Authentication.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @authentication }
    end
  end

  # GET /authentications/new
  # GET /authentications/new.json
  def new
    @authentication = Authentication.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @authentication }
    end
  end

  # GET /authentications/1/edit
  def edit
    @authentication = Authentication.find(params[:id])
  end

  # POST /authentications
  # POST /authentications.json
  def create
    # tradeya user can now add verifications for facebook, twitter and linkedin
    if request.env['omniauth.params']['add_verification'] and current_user
      omniauth = request.env["omniauth.auth"]
      authentication = Authentication.find_by_user_id_and_provider_and_uid(current_user.id,
                                                                           omniauth['provider'],
                                                                           omniauth['uid'])
      if authentication
        authentication.access_token = omniauth.credentials.token
        authentication.access_secret = omniauth.credentials.secret
        authentication.verified = true
        authentication.save
      else
        current_user.authentications.create!(:provider => omniauth['provider'],
                                             :uid => omniauth['uid'],
                                             :access_token => omniauth.credentials.token,
                                             :access_secret => omniauth.credentials.secret)
      end
      # User.update_friend_list(current_user.id,omniauth['provider'])
      flash[:notice] = "Authentication successful."
      if params[:twitter] == "true"
        redirect_to following_user_url(current_user) + "?twitter=true"
        return
      elsif params[:provider] == "facebook"
        redirect_to following_user_url(current_user) + "?facebook=true"
        return
      else
        redirect_to add_verification_success_url
        return
      end
    else
      if session.has_key?("user_ll") then session.delete("user_ll") end
      omniauth = request.env["omniauth.auth"]

      if omniauth and omniauth.credentials then session["facebook_token"] = omniauth.credentials.token end
      session["facebook_zipcode"] = omniauth['info']['location']
      authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
      signin = User.find_by_email(omniauth['info']['email'])

      if authentication
        flash[:notice] = "Signed in successfully."
        authentication.access_token = omniauth.credentials.token
        authentication.access_secret = omniauth.credentials.secret
        authentication.save
        sign_in_and_redirect(:user, authentication.user)
      elsif signin
        signin.confirm! unless signin.confirmed?
        if signin.is_guest_user then signin.update_attributes(:is_guest_user => false) end
        signin.authentications.create!(:provider => omniauth['provider'],
                                       :uid => omniauth['uid'],
                                       :access_token => omniauth.credentials.token,
                                       :access_secret => omniauth.credentials.secret)
        # User.update_friend_list(signin.id,omniauth['provider'])
        flash[:notice] = "Signed in successfully."
        sign_in_and_redirect(:user, signin)
      elsif current_user
        current_user.authentications.create!(:provider => omniauth['provider'],
                                             :uid => omniauth['uid'],
                                             :access_token => omniauth.credentials.token,
                                             :access_secret => omniauth.credentials.secret)
        # User.update_friend_list(current_user.id,omniauth['provider'])
        flash[:notice] = "Authentication successful."
        # redirect_to authentications_url
        redirect_to edit_verifications_url
      else
        user = User.new
        user.apply_omniauth(omniauth)
        user.skip_confirmation!
        if user.email.blank? && omniauth['provider']=='facebook'
          redirect_to(failure_network_url) and return
        elsif user.save
          user.save_tracking_info(session[:track]) # get the utm params and affliate codes
          if session[:sbx_code].present?
            Resque.enqueue(FireTrackingPixelJob, user.id, 'signup')
          end
          sign_in_and_redirect user, :event => :authentication
        else
          session[:omniauth] = omniauth.except('extra')
          redirect_to new_user_registration_url
        end
      end
    end
  end

  # PUT /authentications/1
  # PUT /authentications/1.json
  def update
    @authentication = Authentication.find(params[:id])

    respond_to do |format|
      if @authentication.update_attributes(params[:authentication])
        format.html { redirect_to @authentication, notice: 'Authentication was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @authentication.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authentications/1
  # DELETE /authentications/1.json
  def destroy
    @authentication = current_user.authentications.find(params[:id])
    provider = @authentication.provider
    if provider == 'facebook'
      @authentication.verified = false
      @authentication.save
    else
      @authentication.destroy
    end
    # User.update_friend_list(current_user.id,provider)
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
  end

  def after_sign_in_path_for(resource)
    session[:user_visited_hello] = true
    if request.env["omniauth.auth"]["provider"].present? and request.env["omniauth.auth"]["provider"] == "twitter"
      '/items?category=all'
    elsif request.env["omniauth.auth"]["provider"].present? and request.env["omniauth.auth"]["provider"] == "facebook"
      # '/facebook_sign_in_success'
      facebook_sign_in_success_path
    else
      '/items?category=all'
    end
    
  end

end
