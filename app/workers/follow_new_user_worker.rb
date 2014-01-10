class FollowNewUserWorker
	@queue = :marketing
  def self.perform(new_user_id)
    u = User.find_by_id(new_user_id)
    # facebook friends
    if u.facebook_authenticated?
      begin
        facebook_friends = u.facebook_friends
        fb_uids = facebook_friends.collect{ |f| f["id"] }
        fb_friends_authentications  = u.fb_friends_authentications(fb_uids)
        facebook_registered_friends = fb_friends_authentications.collect{ |f| f["user_id"] }
        puts u.id.to_s + ". " + u.first_name + " Facebook Friends: " + facebook_registered_friends.to_s
      rescue StandardError => e
        facebook_registered_friends = []
      end
    end

    # twitter friends
    if u.twitter_authenticated?
      begin
        twitter_friends = u.twitter_friends
        tw_uids = twitter_friends.collect{ |t| t.to_s}
        tw_friends_authentications = u.tw_friends_authentications(tw_uids)
        twitter_registered_friends = tw_friends_authentications.collect{ |f| f["user_id"] }
        puts u.id.to_s + ". " + u.first_name + " Twitter Friends: " + twitter_registered_friends.to_s
      rescue StandardError => e
        twitter_registered_friends = []
      end
    end

    # follow facebook friends
    if facebook_registered_friends.present?
      facebook_registered_friends.each do |facebook_friend|
      	fb_friend = User.find_by_id(facebook_friend)
        find_follow = u.follows.where(:followed_id => facebook_friend)
        if !find_follow.present?
          u.follows.create(:followed_id => facebook_friend)
        end
        find_other_user_follow = fb_friend.follows.where(:followed_id => u.id)
        if !find_other_user_follow.present?
          fb_friend.follows.create(:followed_id => u.id)
        end
      end
    end

    # follow twitter friends
    if twitter_registered_friends.present?
      twitter_registered_friends.each do |twitter_friend|
      	tw_friend = User.find_by_id(twitter_friend)
        find_follow = u.follows.where(:followed_id => twitter_friend)
        if !find_follow.present?
          u.follows.create(:followed_id => twitter_friend)
        end
        find_other_user_follow = tw_friend.follows.where(:followed_id => u.id)
        if !find_other_user_follow.present?
          tw_friend.follows.create(:followed_id => u.id)
        end
      end
    end

  end
end