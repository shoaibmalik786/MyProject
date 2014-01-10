Tradeya::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :redis_store

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # config.assets.digest = true

  # Expands the lines which load the assets
  config.assets.debug = true
  config.serve_static_assets = true
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  DOMAIN = 'localhost'

  LINKEDIN_CONSUMER_KEY = "gsn7gv3itsb6"
  LINKEDIN_CONSUMER_SECRET = "9smAqCwEv7JPa4QA"
  LINKEDIN_CONFIGURATION = { :site => 'https://api.linkedin.com',
    :authorize_path => '/uas/oauth/authenticate',
    :request_token_path =>'/uas/oauth/requestToken?scope=r_basicprofile+r_emailaddress+r_network+r_contactinfo+rw_nus',
    :access_token_path => '/uas/oauth/accessToken' }

  OPENTOK_API_KEY = "16274641"
  OPENTOK_API_SECRET = "7859d3857cb8a439d185f283ca1c747b01f8a107"
  SERVER_LOCATION = "localhost"

  KISS_METRICS_KEY = "ba5937ff98660bd189c26c36278ae785349062a6"
  GOOGLE_ANALYTICS_KEY = "UA-34137860-1"
  MIXPANEL_TOKEN = "5c3e48ad2d11912f3c3b1d19246a2af2"

  TWILIO_ACCOUNT_SID = 'AC2f99dd6430f9ff889fd010d9c3508ca8'
  TWILIO_AUTH_TOKEN = 'd784ea3088c3b0e8fc2f1d368a66b9c4'
  YOUR_CALLER_ID = '+13104399006'

  AWS_ASSETS_BUCKET = "assets-tradeya-dev"

  CLOUD_SPONGE_DOMAIN_KEY = "Q3XP25FRT7AMBWQGSWTF"

  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    # Bullet.growl = true
    # Bullet.xmpp = { :account  => 'bullets_account@jabber.org',
    #                :password => 'bullets_password_for_jabber',
    #                :receiver => 'your_account@jabber.org',
    #                :show_online_status => true }
    Bullet.rails_logger = true
    Bullet.airbrake = false
    Bullet.add_footer = true
  end
end
