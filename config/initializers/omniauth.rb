Rails.application.config.middleware.use OmniAuth::Builder do

  # provider :linkedin, LINKEDIN_CONSUMER_KEY, LINKEDIN_CONSUMER_SECRET, {:scope => 'r_fullprofile, r_emailaddress'}

  provider :twitter, ENV["TWITTER_KEY"], ENV["TWITTER_SECRET"]
  provider :facebook, ENV["FACEBOOK_KEY"], ENV["FACEBOOK_SECRET"], 
    {:scope => 'email, user_location, friends_location', 
     :client_options => {:ssl => {:ca_path => "/etc/ssl/certs"}}, 
     :display => "popup",
     :provider_ignores_state => true}

end
