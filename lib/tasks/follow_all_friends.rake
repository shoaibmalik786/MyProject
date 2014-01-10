require 'logger'

desc "Make users automatically follow their social network friends on Tradeya."
namespace :marketing do
  task :follow_all_social_friends => :environment do
    logger = Logger.new('log/follow_all_social_friends.log')

    logger.info Time.current
    logger.info "Rake Task Started...."
    User.find_each(batch_size: 100) do |u|
      # facebook friends
      if u.facebook_authenticated?
        begin
          facebook_friends = u.facebook_friends
          fb_uids = facebook_friends.collect{ |f| f["id"] }
          fb_friends_authentications  = u.fb_friends_authentications(fb_uids)
          facebook_registered_friends = fb_friends_authentications.collect{ |f| f["user_id"] }
          logger.info "------------------------------------------------------"
          logger.info u.id.to_s + " - " + u.first_name + " Facebook Friends: " + facebook_registered_friends.to_s
        rescue StandardError => e
          logger.info "------------------------------------------------------"
          logger.info u.id.to_s + " - " + u.first_name + " Facebook Error:"
          logger.info e
        end
      end

      # twitter friends
      if u.twitter_authenticated?
        begin
          twitter_friends = u.twitter_friends
          tw_uids = twitter_friends.collect{ |t| t.to_s}
          tw_friends_authentications = u.tw_friends_authentications(tw_uids)
          twitter_registered_friends = tw_friends_authentications.collect{ |f| f["user_id"] }
          logger.info "------------------------------------------------------"
          logger.info u.id.to_s + " - " + u.first_name + " Twitter Friends: " + twitter_registered_friends.to_s
        rescue StandardError => e
          logger.info "------------------------------------------------------"
          logger.info u.id.to_s + " - " + u.first_name + " Twitter Error:"
          logger.info e
        end
      end

      # follow facebook friends
      if facebook_registered_friends.present?
        facebook_registered_friends.each do |facebook_friend|
          find_follow = u.follows.where(:followed_id => facebook_friend)
          if !find_follow.present?
            u.follows.create(:followed_id => facebook_friend)
          end
        end
      end

      # follow twitter friends
      if twitter_registered_friends.present?
        twitter_registered_friends.each do |twitter_friend|
          find_follow = u.follows.where(:followed_id => twitter_friend)
          if !find_follow.present?
            u.follows.create(:followed_id => twitter_friend)
          end
        end
      end

    end #loop
    logger.info "------------------------------------------------------"
    logger.info "Rake Task Ended..."
    logger.info Time.current
    logger.info "=========================================================================================================="
  end #task
end #namespace
