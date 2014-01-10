class Api::V1::SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token,
    :if => Proc.new { |c| c.request.format == 'application/json' }

  prepend_before_filter :require_no_authentication, :only => [:create]
  before_filter :authenticate_user_from_token!, :except => [:create]  
  include Devise::Controllers::Helpers
  respond_to :json

  def create
    if (params[:auth])
      auth(params[:auth])
    else
      resource = User.find_for_database_authentication(:email => params[:user][:email])
      return failure unless resource
      
      if resource.valid_password?(params[:user][:password])
        sign_in(:user, resource)
        resource.ensure_authentication_token
        render :status => 200,
          :json => { :success => true,
                    :info => "Logged in",
                    :data => {
                              :auth_token => resource.authentication_token,
                              :email => resource.email,
                              :id => resource.id
                             }
                   }
        return
      end
      failure
    end
  end

  def destroy
    current_user.update_column(:authentication_token, nil)
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)    
    render :status => 200,
      :json => { :success => true,
                :info => "Logged out",
                :data => {} 
               }
  end

  def failure
    render :status => 401,
      :json => { 
                :success => false,
                :info => "Login Failed",
                :data => {} 
               }
  end

  private
  def auth(auth)
    # check for auth hash presence
    unless auth
      return failure
    end
    # find authentication using auth hash
    authentication = Authentication.find_by_provider_and_uid(auth['provider'],
                                                             auth['uid'])
    user = User.find_by_email(auth['email']) unless auth['email'].blank?
    # if present
    if authentication.nil?
      # user = User.find_by_email(auth['email']) unless auth['email'].blank?
      if user.nil?
        user = User.new(auth['info'])
      end
      user.authentications.build(:provider => auth['provider'],
                                 :uid => auth['uid'],
                                 :access_token => auth['access_token'],
                                 :access_secret =>  auth['access_token'])
      # user.authenticaion = authentication
      user.skip_confirmation!
      user.save
    else
      user = authentication.user
    end

    sign_in(:user, user)
    warden.authenticate!(:scope => :user, :recall => "#{controller_path}#failure")
    render :status => 200,
      :json => { :success => true,
                :info => "Logged in",
                :data => { 
                          :auth_token => current_user.authentication_token,
                          :id => current_user.id,
                          :email => current_user.email
                         } 
               }
  end

end
