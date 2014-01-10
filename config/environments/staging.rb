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

  config.action_mailer.default_url_options = { :host => 'tradeya.addvalsolutions.com' }

  config.middleware.use ExceptionNotifier,
    :email_prefix => "[TradeYa App] ",
    :sender_address => %{"TradeYa Exception Notifier" <trd-errors@addvalsolutions.com>},
    :exception_recipients => %w{tradeya-dev@addvalsolutions.com}

  DOMAIN = 'tradeya.addvalsolutions.com'

  FACEBOOK_CONSUMER_KEY = "400641706632763"
  FACEBOOK_CONSUMER_SECRET = "e1528ef7280149b95753b62d1b013f2a"

  TWITTER_CONSUMER_KEY = "QUoeGJChENoBeHf3hzW2zA"
  TWITTER_CONSUMER_SECRET = "sb769D6lPNobBGczos8g5hvERhDDRR2QylYJ8LNC4s&"
  TWITTER_CONSUMER_SECRET_ONLY = "sb769D6lPNobBGczos8g5hvERhDDRR2QylYJ8LNC4s"
  TWIT_PIC_API_KEY = "854595abc038c3030e39fd149410ad69"

  LINKEDIN_CONSUMER_KEY = "dc8dbjve1q1c"
  LINKEDIN_CONSUMER_SECRET = "Lw5qarnHB4omGu7j"
  LINKEDIN_CONFIGURATION = { :site => 'https://api.linkedin.com',
    :authorize_path => '/uas/oauth/authenticate',
    :request_token_path =>'/uas/oauth/requestToken?scope=rw_nus+r_basicprofile+r_emailaddress+r_network+r_contactinfo',
    :access_token_path => '/uas/oauth/accessToken' }

  # AWEBER_CONSUMER_KEY = "AkNJKcfXMsKJbchvKA4fV8sL"
  # AWEBER_CONSUMER_SECRET = "QAStdVmOTSEXDihfjVJJDDY7d34FleOrLHdXFyQI"
  # AWEBER_APP_ID = "f734ca35"
  # AWEBER_LIST_NAME = "tradeya-stg"

  OPENTOK_API_KEY = "16274641"
  OPENTOK_API_SECRET = "7859d3857cb8a439d185f283ca1c747b01f8a107"
  SERVER_LOCATION = 'tradeya.addvalsolutions.com'

  KISS_METRICS_KEY = "ba5937ff98660bd189c26c36278ae785349062a6"
  GOOGLE_ANALYTICS_KEY = "UA-34137860-1"

  TWILIO_ACCOUNT_SID = 'AC2f99dd6430f9ff889fd010d9c3508ca8'
  TWILIO_AUTH_TOKEN = 'd784ea3088c3b0e8fc2f1d368a66b9c4'
  YOUR_CALLER_ID = '+13104399006'

  AWS_ASSETS_BUCKET = "assets-tradeya-stg"
end
