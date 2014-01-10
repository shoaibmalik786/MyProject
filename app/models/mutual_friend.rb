class MutualFriend < ActiveRecord::Base
  require 'httparty'

  def self.update_mutual_friends(u)
    update_fb_mutual_friends(u)
    update_tw_mutual_friends(u)
    update_ln_mutual_friends(u)
  end

  def self.update_fb_mutual_friends(u)
    begin
      u1_fb = []
      begin
        a = u.authentication('facebook')
        if a.nil? or a.access_token.nil?
          self.remove_existing_fb_records(u)
          return
        end
        u_fs = HTTParty.get('https://graph.facebook.com/' + a.uid + '/friends?access_token=' + a.access_token + '&limit=5000')
        d = JSON.parse(u_fs.body)["data"]
        if d.nil?
          puts "No FB data found for user : " + u.id.to_s 
          return
        else
          d.each do |f|
            arr = Hash.new
            arr["image"] = User.user_image_by_uid(f["id"])
            arr["name"] = f["name"]
            arr["uid"] = f["id"]
            u1_fb.push(arr)
          end
        end
      rescue StandardError => e
        puts "Something went wrong." + e.message + "\n" + e.backtrace.to_s
        e = nil
      end
      u.fb_friends_count = u1_fb.count
      u.save

      # update friends data in mutual_friends table
      User.all.each do |u2|
        if u.id == u2.id then next end
        u2_fb = []

        begin
          a = u2.authentication('facebook')
          if a.nil? or a.access_token.nil? then next end
          u_fs = HTTParty.get('https://graph.facebook.com/' + a.uid + '/friends?access_token=' + a.access_token + '&limit=5000')
          d = JSON.parse(u_fs.body)["data"]
          if d.nil?
            puts "No FB data found for user : " + u2.id.to_s 
          else
            d.each do |f|
              arr = Hash.new
              arr["image"] = User.user_image_by_uid(f["id"])
              arr["name"] = f["name"]
              arr["uid"] = f["id"]
              u2_fb.push(arr)
            end
          end
        rescue StandardError => e
          puts "Something went wrong." + e.message + "\n" + e.backtrace.to_s
          e = nil
        end
        mutual_frnds = []
        uids = ""

        u1_fb.each do |f1|
          u2_fb.each do |f2|
            if f1["uid"] == f2["uid"]
              mutual_frnds.push(f1)
              uids = uids + (uids.length == 0 ? "" : ",") + "'" + f1["uid"] + "'"
              break
            end
          end
        end

        if mutual_frnds.count > 0 then mutual_frnds = u.update_fb_friends_locations(mutual_frnds, uids) end

        mf_key = get_mf_key(u.id, u2.id)
        mf = MutualFriend.find(:first, :conditions => {:key => mf_key})
        if mf.nil?
          mf = MutualFriend.new
          mf.key = mf_key
        end
        mf.fb_mutual_friends_count = mutual_frnds.count
        mf.fb_mutual_friends = mutual_frnds.to_json
        mf.save
      end
    rescue StandardError => e
      puts "Something went wrong." + e.message + "\n" + e.backtrace.to_s
      e = nil
    end
  end

  def self.update_tw_mutual_friends(u)
    begin
      u1_tw = []
    
      begin
        a = u.authentication('twitter')
        mt_ids = ""
        if a.nil?
          self.remove_existing_tw_records(u)
          return
        end

        u_fs = HTTParty.get('https://api.twitter.com/1/friends/ids.json?user_id=' + a.uid.to_s)
        d = JSON.parse(u_fs.body)["ids"]
        if d.nil?
          puts "No TW data found for user : " + u.id.to_s 
          return
        else
          d.each do |f|
            mt_ids = mt_ids.blank? ? "#{d[d.index(f)]}" : "#{mt_ids},#{d[d.index(f)]}"
          end
          if !mt_ids.blank?
            details = HTTParty.get('https://api.twitter.com/1/users/lookup.json?user_id=' + mt_ids)
            friends = JSON.parse(details.body)
            friends.each do |f|
              arr = Hash.new
              arr["image"] = f["profile_image_url"]
              arr["name"] = f["name"]
              arr["uid"] = f["id_str"]
              arr["location"] = f["location"]
              u1_tw.push(arr)
            end
          end
        end
      rescue StandardError => e
        puts "Something went wrong." + e.message + "\n" + e.backtrace.to_s
        e = nil
      end

      u.tw_friends_count = u1_tw.count
      u.save

      User.all.each do |u2|
        if u.id == u2.id then next end
        u2_tw = []

        begin
          a = u2.authentication('twitter')
          mt_ids = ""
          if a.nil? then next end

          u_fs = HTTParty.get('https://api.twitter.com/1/friends/ids.json?user_id=' + a.uid.to_s)
          d = JSON.parse(u_fs.body)["ids"]
          if d.nil?
            puts "No TW data found for user : " + u2.id.to_s 
          else
            d.each do |f|
              mt_ids = mt_ids.blank? ? "#{d[d.index(f)]}" : "#{mt_ids},#{d[d.index(f)]}"
            end
            if !mt_ids.blank?
              details = HTTParty.get('https://api.twitter.com/1/users/lookup.json?user_id=' + mt_ids)
              friends = JSON.parse(details.body)
              friends.each do |f|
                arr = Hash.new
                arr["image"] = f["profile_image_url"]
                arr["name"] = f["name"]
                arr["uid"] = f["id_str"]
                arr["location"] = f["location"]
                u2_tw.push(arr)
              end
            end
          end
        rescue StandardError => e
          puts "Something went wrong." + e.message + "\n" + e.backtrace.to_s
          e = nil
        end

        mutual_frnds = []
        u1_tw.each do |f1|
          u2_tw.each do |f2|
            if f1["uid"] == f2["uid"]
              mutual_frnds.push(f1)
              break
            end
          end
        end

        mf_key = get_mf_key(u.id, u2.id)
        mf = MutualFriend.find(:first, :conditions => {:key => mf_key})
        if mf.nil?
          mf = MutualFriend.new
          mf.key = mf_key
        end
        mf.tw_mutual_friends_count = mutual_frnds.count
        mf.tw_mutual_friends = mutual_frnds.to_json
        mf.save
      end
    rescue StandardError => e
      puts "Something went wrong." + e.message + "\n" + e.backtrace.to_s
      e = nil
    end
  end

  def self.update_ln_mutual_friends(u)
    begin
      u1_ln = []
      begin
        a1 = u.authentication('linkedin')
        if a1.nil? or a1.access_token.nil?
          self.remove_existing_ln_records(u)
          return
        end

        client = LinkedIn::Client.new(LINKEDIN_CONSUMER_KEY, LINKEDIN_CONSUMER_SECRET, LINKEDIN_CONFIGURATION)
        client.authorize_from_access(a1.access_token, a1.access_secret)
        cons1 = client.connections
        cons1.all.each do |c1|
          if c1.id != 'private'
            arr = Hash.new
            arr["image"] = (c1.picture_url.nil? ? "https://s3.amazonaws.com/tradeya_prod/tradeya/images/TY_DefaultUser_sm.gif" : c1.picture_url)
            arr["name"] = c1.first_name + ((c1.last_name.nil? or c1.last_name.length == 0) ? "" : " ") + c1.last_name
            arr["uid"] = c1.id
            arr["location"] = (c1.location.nil? ? "" : c1.location.name)
            u1_ln.push(arr)
          end
        end
      rescue StandardError => e
        puts "Something went wrong." + e.message + "\n" + e.backtrace.to_s
        e= nil
      end

      u.ln_friends_count = u1_ln.count
      u.save

      User.all.each do |u2|
        if u.id == u2.id then next end
        u2_ln = []

        begin
          a = u2.authentication('linkedin')
          if a.nil? or a.access_token.nil? then next end

          mt_ids = ""
          # client = LinkedIn::Client.new(LINKEDIN_CONSUMER_KEY, LINKEDIN_CONSUMER_SECRET, LINKEDIN_CONFIGURATION)
          client.authorize_from_access(a.access_token, a.access_secret)
          cons = client.connections
          cons.all.each do |c|
            if c.id != 'private'
              arr = Hash.new
              arr["image"] = (c.picture_url.nil? ? "https://s3.amazonaws.com/tradeya_prod/tradeya/images/TY_DefaultUser_sm.gif" : c.picture_url)
              arr["name"] = c.first_name + ((c.last_name.nil? or c.last_name.length == 0) ? "" : " ") + c.last_name
              arr["uid"] = c.id
              arr["location"] = (c.location.nil? ? "" : c.location.name)
              u2_ln.push(arr)
            end
          end
        rescue StandardError => e
          puts "Something went wrong." + e.message + "\n" + e.backtrace.to_s
          e = nil
        end

        mutual_frnds = []

        u1_ln.each do |f1|
          u2_ln.each do |f2|
            if f1["uid"] == f2["uid"]
              mutual_frnds.push(f1)
              break
            end
          end
        end

        mf_key = get_mf_key(u.id, u2.id)
        mf = MutualFriend.find(:first, :conditions => {:key => mf_key})
        if mf.nil?
          mf = MutualFriend.new
          mf.key = mf_key
        end
        mf.ln_mutual_friends_count = mutual_frnds.count
        mf.ln_mutual_friends = mutual_frnds.to_json
        mf.save
      end
    rescue StandardError => e
      puts "Something went wrong." + e.message + "\n" + e.backtrace.to_s
      e = nil
    end
  end

  def self.get_mf_key(u1_id, u2_id)
    return ((u1_id < u2_id) ? (u1_id.to_s + '_' + u2_id.to_s) : (u2_id.to_s + '_' + u1_id.to_s))
  end

  def self.remove_existing_fb_records(u)
    ActiveRecord::Base.connection.execute("UPDATE mutual_friends SET fb_mutual_friends = null, fb_mutual_friends_count = 0 WHERE \"key\" like '#{u.id}\_%' OR \"key\" like '%\_#{u.id}'")
      u.fb_friends_count = 0
      u.save
  end

  def self.remove_existing_tw_records(u)
    ActiveRecord::Base.connection.execute("UPDATE mutual_friends SET tw_mutual_friends = null, tw_mutual_friends_count = 0 WHERE \"key\" like '#{u.id}\_%' OR \"key\" like '%\_#{u.id}'")
      u.tw_friends_count = 0
      u.save
  end

  def self.remove_existing_ln_records(u)
    ActiveRecord::Base.connection.execute("UPDATE mutual_friends SET ln_mutual_friends = null, ln_mutual_friends_count = 0 WHERE \"key\" like '#{u.id}\_%' OR \"key\" like '%\_#{u.id}'")
    u.ln_friends_count = 0
    u.save
  end

  def self.get_mutual_friends_count(u1_id,u2_id)
    count = 0
    mf_key = get_mf_key(u1_id,u2_id)
    record = MutualFriend.find(:first, :conditions => {:key => mf_key})
    if record.nil? 
      return 0
    else
      count = count + record.fb_mutual_friends_count unless record.fb_mutual_friends_count.nil?
      count = count + record.tw_mutual_friends_count unless record.tw_mutual_friends_count.nil?
      count = count + record.ln_mutual_friends_count unless record.ln_mutual_friends_count.nil?
      return count
    end
  end

  def self.get_mutual_friends_details(u1_id,u2_id)
    mf = []
    mf_key = get_mf_key(u1_id,u2_id)
    record = MutualFriend.find(:first, :conditions => {:key => mf_key})
    if record.nil? 
      return mf
    else
      mf.concat(JSON.parse(record.fb_mutual_friends)) unless record.fb_mutual_friends.nil?
      mf.concat(JSON.parse(record.tw_mutual_friends)) unless record.tw_mutual_friends.nil?
      mf.concat(JSON.parse(record.ln_mutual_friends)) unless record.ln_mutual_friends.nil?
      return mf
    end
  end

end
