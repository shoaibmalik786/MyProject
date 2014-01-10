Tradeya::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  #Disable ip_spoofing attack
  config.action_dispatch.ip_spoofing_check = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
  config.cache_store = :redis_store
  # config.action_dispatch.rack_cache = nil

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.action_mailer.default_url_options = { :host => 'www.tradeya.com' }

  # config.middleware.use ExceptionNotification::Rack,
  #   :email => {
  #     :email_prefix => "[TradeYa App] ",
  #     :sender_address => %{"TradeYa Exception Notifier" <trd-errors@addvalsolutions.com>},
  #     :exception_recipients => %w{tradeya-dev@addvalsolutions.com}
  # }

  DOMAIN = 'www.tradeya.com'

  FACEBOOK_CONSUMER_KEY = "120974717953752"
  FACEBOOK_CONSUMER_SECRET = "14339b3c25e71e23228ee9aaf5ca1462"

  TWITTER_CONSUMER_KEY = "Ar3ZtvxvFzYG8Jx1EOHUg"
  TWITTER_CONSUMER_SECRET = "cNGFZ5OD4hGnv8JsNIOdXvhlGnDwn2z1PIitOglQk&"
  TWITTER_CONSUMER_SECRET_ONLY = "cNGFZ5OD4hGnv8JsNIOdXvhlGnDwn2z1PIitOglQk"
  TWIT_PIC_API_KEY = "854595abc038c3030e39fd149410ad69"

  LINKEDIN_CONSUMER_KEY = "sn0tcfd3kia6"
  LINKEDIN_CONSUMER_SECRET = "MLVJxtmXADSmOoue"
  LINKEDIN_CONFIGURATION = { :site => 'https://api.linkedin.com',
    :authorize_path => '/uas/oauth/authenticate',
    :request_token_path =>'/uas/oauth/requestToken?scope=r_basicprofile+r_emailaddress+r_network+r_contactinfo+rw_nus',
    :access_token_path => '/uas/oauth/accessToken' }

  # AWEBER_CONSUMER_KEY = "AkNJKcfXMsKJbchvKA4fV8sL"
  # AWEBER_CONSUMER_SECRET = "QAStdVmOTSEXDihfjVJJDDY7d34FleOrLHdXFyQI"
  # AWEBER_APP_ID = "f734ca35"
  # AWEBER_LIST_NAME = "tradeya"

  OPENTOK_API_KEY = "16274641"
  OPENTOK_API_SECRET = "7859d3857cb8a439d185f283ca1c747b01f8a107"
  SERVER_LOCATION = 'www.tradeya.com'

  KISS_METRICS_KEY = "ed237a9d9508da3be9ad51ae4f90295512551560"
  GOOGLE_ANALYTICS_KEY = "UA-45802856-1"
  MIXPANEL_TOKEN = "5c3e48ad2d11912f3c3b1d19246a2af2"

  TWILIO_ACCOUNT_SID = 'AC2f99dd6430f9ff889fd010d9c3508ca8'
  TWILIO_AUTH_TOKEN = 'd784ea3088c3b0e8fc2f1d368a66b9c4'
  YOUR_CALLER_ID = '+13104399006'

  AWS_ASSETS_BUCKET = "assets-tradeya"

  CLOUD_SPONGE_DOMAIN_KEY = "LFUV8BNNVLM5AGRBR7QV"
end
