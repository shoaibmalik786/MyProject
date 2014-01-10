task :clear_expired_sessions => :environment do
  ActiveRecord::SessionStore::Session.delete_all(["updated_at < ?", 2.weeks.ago])
end
