class ConfirmationController < Devise::ConfirmationsController
  def after_sign_in_path_for(resource)
    # root_url
    session[:user_visited_hello] = true
    items_path + "?category=all&email_signup=true"
  end

  private

  def after_confirmation_path_for(resource_name, resource)
    items_path + "?category=all&email_signup=true"
  end
end
