class PersonMatchingResult < ActiveRecord::Base
  belongs_to :user

  def self.match_result(u)
    pmr = PersonMatchingResult.find(:first, :conditions => {:user_id => u.id, :status => MATCH_PRESENT})
    return pmr
  end

  def person
    pers = self.match_result_q.split(',')
    pids = self.processed_ids.split(',')

    p = pers.shift
    pids[pids.count] = p

    self.processed_ids = pids.join(',')
    self.match_result_q = pers.join(',')

    if self.match_result_q.length == 0
      self.status = MATCH_FINISH
      self.user.is_in_matching_q = true
      self.user.save
    end

    self.save

    p = User.find(p)
    return p
  end

  def matched_interests(p)
    m_cats = JSON.parse(matched_log_data)
    return m_cats[p.id.to_s][2]
  end

  def self.isValidQ(u)
    pmr = PersonMatchingResult.find(:first, :conditions => {:user_id => u.id, :status => MATCH_PRESENT})
    if pmr.present?
      pers = pmr.match_result_q.split(',')
      pids = pmr.processed_ids.split(',')
      not_valid_pers = []

      pers.each do |pid|
        p = User.find(pid)
        if !p.active or p.tradeya_going2expire(false,u.tradeya_match_ids).nil?
          not_valid_pers[not_valid_pers.count] = pid
        end
      end

      not_valid_pers.each do |d|
        pers.delete_at(pers.index(d))
        pids[pids.count] = d
      end

      pmr.processed_ids = pids.join(',')
      pmr.match_result_q = pers.join(',')
      pmr.save

      if pmr.match_result_q.length > 0
        return true
      else
        pmr.status = MATCH_FINISH
        pmr.user.is_in_matching_q = true
        pmr.user.save
        pmr.save
      
        return false
      end
    else
      return false
    end
  end
end
