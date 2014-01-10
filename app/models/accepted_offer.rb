class AcceptedOffer < ActiveRecord::Base
  belongs_to :user
  belongs_to :trade
  has_many :reviews

  def self.recent_tradeyas(limit = 5)
    t = ActiveRecord::Base.connection.execute('SELECT DISTINCT trade_id FROM accepted_offers WHERE recent_tradeya = 1 order by created_at DESC limit ' + limit.to_s)
    tids = ''
    t.each do |ao| tids = tids + ((tids.length == 0) ? '' : ',') + ao[0].to_s end
    tts = Trade.find(:all, :conditions => ['id IN(' + tids + ')'])

    trds = []
    c = 0
    t.each do |ao|
      tts.each do |trd|
        if ao[0] == trd.id
          trds[c] = trd
          break
        end
      end
      c = c + 1
    end

    c = 0
    if limit == 5 and trds.count < 5
      r = trds.count
      ((trds.count)..(5 - 1)).each do |i|
        trds[i] = trds[c]
        if c < r then c = c + 1 else c = 0 end
      end
    end
    return trds
  end

  def self.past_trades
    pt = AcceptedOffer.find(:all, :order => 'created_at desc', :limit => 25)
  end
  
  def self.total_accepted(item_id)
    return Trade.find_by_sql("select * from trades where id in (select trade_id from accepted_offers where trade_id in (select id from trades where item_id = #{item_id}))")
  end
  
  def self.get_tile_images
    finaldata = Array.new
    recent_completed_tradeyas(18).each do |x|
      itm = [0,0]
      if !x.item.item_photos.nil? and x.item.item_photos.length > 0
        itm[0] = "img"
        itm[1] = x.item
        finaldata.push(itm)
      elsif !x.item.item_videos.nil? and x.item.item_videos.length > 0
        itm[0] = "vdo"
        itm[1] = x.item
        finaldata.push(itm)
      end
    end
    if finaldata.count < 18
      count = 0
      (finaldata.count..18).each do |x|
        finaldata.push(finaldata[count])
        count += 1
      end
    end
    return finaldata
  end
  
  def self.recent_completed_tradeyas(limit = nil)
    today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    # query = "select tr.* from trades tr, items i, accepted_offers acc where tr.item_id = i.id and tr.id = acc.trade_id and i.tod = true and (i.exp_date < '#{today}' or i.status = 'COMPLETED') and acc.recent_tradeya = true order by acc.created_at desc"
    query = "select tr.* from trades tr, items i, accepted_offers acc where tr.item_id = i.id and tr.id = acc.trade_id and i.tod = true and i.status = 'COMPLETED' and acc.recent_tradeya = true order by acc.created_at desc"
    if not limit.nil?
      query = query +  " limit #{limit} "
    end
    trades =  Trade.find_by_sql(query)
  end
  
  def self.get_anchor_for_offer(item_id,user_id)
    acc = self.find_by_sql("select * from accepted_offers where trade_id in (select id from trades where item_id = #{item_id} and offer_id in (select id from items where user_id = #{user_id}))")
    if acc.length == 0
      return "current" 
    else
      return "accepted"
    end
  end

  def self.check_default_case(tr,limit = 5,is_dup_allow = true)
    if tr.nil? || tr.length == 0
      tr = [Trade.last]
    end
    
    if is_dup_allow
      if tr.count < limit
        c = 0
        r = tr.count
        ((tr.count)..(limit - 1)).each do |i|
          tr[i] = tr[c]
          if c < r then c = c + 1 else c = 0 end
        end
      end
     end
    
    return tr
  end

  def self.find_by_ids(str)
    if !str.nil? and str.length > 0 
      return Trade.find(:all, :conditions => " ID in (#{str}) ")
    else
      return []
    end
  end

end
