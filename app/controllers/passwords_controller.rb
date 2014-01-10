class PasswordsController < Devise::PasswordsController
  
   def create
    # u = User.find_by_email(params[resource_name]["email"])
    # if u and u.authentications.length > 0
    #   session["user"] = u
    # else
      self.resource = resource_class.send_reset_password_instructions(params[resource_name])
      session["user"] = self.resource

      # successfully_sent?(resource)
      #respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
    # end
    redirect_to password_reset_url
  end
  
  def after_sending_reset_password_instructions_path_for(user)
    password_reset_url
  end
   
  def after_sign_in_path_for(user)
    password_changed_url
  end
end
