class TradeyaMatchingResult < ActiveRecord::Base
  belongs_to :user

  def self.match_result(u)
    tmr = TradeyaMatchingResult.find(:first, :conditions => {:user_id => u.id, :status => MATCH_PRESENT})
    return tmr
  end

  def tradeya
    trds = self.match_result_q.split(',')
    pids = self.processed_ids.split(',')

    t = trds.shift
    pids[pids.count] = t

    self.processed_ids = pids.join(',')
    self.match_result_q = trds.join(',')

    if self.match_result_q.length == 0
      self.status = MATCH_FINISH
      self.user.is_in_matching_q = true
      self.user.save
    end

    self.save

    t = Item.find(t)
    return t
  end

  def self.isValidQ(u)
    already_matched_ids = []
    tmr = TradeyaMatchingResult.find(:first, :conditions => {:user_id => u.id, :status => MATCH_PRESENT})
    if tmr.present?
      tdrs = tmr.match_result_q.split(',')
      pids = tmr.processed_ids.split(',')
      already_matched_ids = u.tradeya_match_ids.split(',')
      not_valid_tdrs = []

      tdrs.each do |tid|
        i = Item.find(tid)
        if !(i.live?) or !i.user.active or already_matched_ids.include?(tid)
          not_valid_tdrs[not_valid_tdrs.count] = tid
        end
      end

      not_valid_tdrs.each do |d|
        tdrs.delete_at(tdrs.index(d))
        pids[pids.count] = d
      end

      tmr.processed_ids = pids.join(',')
      tmr.match_result_q = tdrs.join(',')
      tmr.save

      if tmr.match_result_q.length > 0
        return true
      else
        tmr.status = MATCH_FINISH
        tmr.user.is_in_matching_q = true
        tmr.user.save
        tmr.save
      
        return false
      end
    else
      return false
    end
  end
end
