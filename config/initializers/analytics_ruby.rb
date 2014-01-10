Analytics = AnalyticsRuby       # Alias for convenience
Analytics.init({
    secret: ENV['ANALYTICS_KEY'],          # The write key for username/acme-co
    on_error: Proc.new { |status, msg| print msg }  # Optional error handler
})