Split.configure do |config|
  config.db_failover = true # handle redis errors gracefully
  config.db_failover_on_db_error = proc{|error| Rails.logger.error(error.message) }
  config.allow_multiple_experiments = true
  config.enabled = true
  # config.persistence = Split::Persistence::SessionAdapter
end

Split::Dashboard.use Rack::Auth::Basic do |username, password|
  username == 'admin@tradeya.com' && password == 'tradeyarules1!'
end