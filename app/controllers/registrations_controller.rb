class RegistrationsController < Devise::RegistrationsController
  # before_filter :require_user

  cache_sweeper :user_sweeper, :only => [:create]

  def create
    if params[:user].present?
      build_resource(sign_up_params)
      session[:omniauth] = nil unless resource.new_record?
      session["signup_user"] = resource
      if resource.save

        resource.save_tracking_info(session[:track]) #save google utm params and affilate codes

        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_navigational_format?
          sign_in(resource_name, resource)
          respond_with resource, :location => after_sign_up_path_for(resource)
          # redirect_to items_path + "?category=all"
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
          expire_session_data_after_sign_in!
          session[:param2] = "signup"
        end
      else
        clean_up_passwords resource
        respond_to do |format|
          format.html {render :action => "new"}
          format.js
        end

      end
    else
      render :text => "Request not valid."
    end
  end

  def change_user_password
    if current_user
      # the second condition in the next if is for users with social logins
      if current_user.valid_password?(current_user[:current_password]) ||
          !current_user.encrypted_password.present?



          # debugger
        if current_user.update_attributes(params[:user])
         #debugger
        # Sign in the user by passing validation in case his password changed


        if current_user.update_attributes(current_user)
          # Sign in the user by passing validation in case his password changed
          sign_in current_user, :bypass => true
          redirect_to after_change_password_url
        if current_user.update_attributes(params[:user])

          # Sign in the user by passing validation in case his password changed
          if current_user.update_attributes(current_user)
            # Sign in the user by passing validation in case his password changed
            sign_in current_user, :bypass => true
            redirect_to after_change_password_url
          else
            redirect_to after_change_password_url, :flash => {:error => current_user.errors.full_messages}
          end

        else
          redirect_to after_change_password_url, :flash => {:error => current_user.errors.full_messages}
        end
      else
        redirect_to after_change_password_url, :flash => { :error => ["Invalid Old Password"] }
      end
    else
      redirect_to "/"
      return
    end
  end

  def deactivate_account
    if current_user
      current_user.active = false
      current_user.save

      EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_YOUR_ACCOUNT_DEACTIVATED, current_user.id)
    end

    redirect_to destroy_user_session_url
  end

  private
  def build_resource(*args)
    super
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @user.valid?
    end
  end


  protected
    def after_inactive_sign_up_path_for(resource)
    # the page prelaunch visitors will see after they request an invitation
    # unless Ajax is used to return a partial
    '/thankyou.html'
    end
    
    def after_sign_up_path_for(resource)
      # the page new users will see after sign up (after launch, when no invitation is needed)
      redirect_to items_path + "?category=all"
    end

    def after_update_path_for(resource)
    edit_user_path(current_user)
    end

end
end
end
