class SessionsController < Devise::SessionsController
  # before_filter :require_user

  def create
    user = User.find_by_email(params[:user][:email]) if params[:user].present?
    if user.present? and user.facebook_authenticated?
      redirect_to failure_path(:fb_user => "true")
    else
      resource = warden.authenticate!(:scope => resource_name, :recall => 'sessions#failure')
      sign_in_and_redirect(resource_name, resource)
    end
  end

  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    if request.xhr?
      render :json => {
                       :id => resource.id,
                       :count => resource.sign_in_count,
                       :success => true,
                       :profile => 3,
                       :redirect => stored_location_for(scope) || after_sign_in_path_for(resource)} and return
    else
      redirect_to after_sign_in_path_for(resource)
    end
  end

  def failure
    if params[:fb_user] == "true"
      render :json => {:success => false, :fb_user => true, :errors => "Login failed."} and return
    else
      # render :json => {:success => false, :errors => "Login failed."} and return
      render :action => "new"
    end
  end

  def destroy
    redirect_path = after_sign_out_path_for(resource_name)
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out && is_navigational_format?

    session[:user_visited_hello] = true
    session[:hello_modal_timer] = nil
    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.any(*navigational_formats) { redirect_to redirect_path }
      format.all do
        head :no_content
      end
    end
  end


  # def create
  #   resource = warden.authenticate!(auth_options)
  #   set_flash_message(:notice, :signed_in) if is_navigational_format?
  #   sign_in(resource_name, resource)

  #   if session.has_key?("user_ll") then session.delete("user_ll") end
  #   respond_with resource, :location => after_sign_in_path_for(resource)

  # end

  # def auth_options
  #   { :scope => resource_name, :recall => "/sign_in_success" }
  # end

  # DELETE /resource/sign_out

  # def after_sign_in_path_for(resource)
  #   session[:user_visited_hello] = true
  #   session[:pub] = nil
  #   render :text => 'true:profile:3' #+ user_profile_status

  #   # '/sign_in_success'
  # end

  # def after_sign_out_path_for(resource_name)
  #   session[:user_visited_hello] = true
  #   '/'
  # end
end
