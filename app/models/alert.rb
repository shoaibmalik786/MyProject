class Alert < ActiveRecord::Base
  belongs_to :item
  belongs_to :trade
  belongs_to :user

  self.per_page = 25

  def get_partial_name_by_alert_no
    return ALERT_NO_HASH[alert_no]
  end

  def self.add_2_alert_q(alert_type, alert_no, user_id, item_id = nil, trade_id = nil)
    a = nil
    if alert_no == OFFER_RATED or alert_no == NEW_OFFER_ON_TRADEYA or alert_no == NEW_COMMENT_ON_TRADEYA_4_OFFERER or alert_no == NEW_COMMENT_ON_TRADEYA_4_PUB
      a = Alert.find(:first, :conditions => {:user_id => user_id, :alert_no => alert_no, :item_id => item_id, :trade_id => trade_id, :is_new => true}, :order => "created_at DESC")
    end
    if a.nil?
      a = Alert.new({:alert_type => alert_type, :alert_no => alert_no, :user_id => user_id, :item_id => item_id, :trade_id => trade_id, :count => 1})
    else
      a.count = a.count + 1 #((a.count == 0) ? 2 : 1)
    end
    a.save
  end

  def self.user_new_alert_count(user_id)
    return Alert.count(:all,:select => 'id', :conditions => {:user_id => user_id, :is_new => true})
  end
  
  def self.user_alert_count(user_id)
    return Alert.count(:all,:select => 'id', :conditions => {:user_id => user_id})
  end

  def self.user_alerts(user_id, page = nil, last_alert_id = nil, filter = nil)
    last_alert_id_cond = ""

    if last_alert_id
      last_alert_id_cond = " AND id < " + last_alert_id.to_s
    end

    if filter.nil? or filter.to_i == 0
      return Alert.where("user_id = #{user_id}" + last_alert_id_cond).paginate(:page => page).order('id DESC')
    else
      return Alert.where("user_id = #{user_id} AND alert_type = #{filter}" + last_alert_id_cond).paginate(:page => page).order('id DESC')
    end
  end

  def self.get_new_alerts(user_id, last_id, filter)
    if filter.to_i > 0
      return Alert.find(:all, :conditions => ["user_id = ? AND id > ? AND alert_type = ?", user_id, last_id, filter], :order => 'id DESC')
    else
      return Alert.find(:all, :conditions => ["user_id = ? AND id > ?", user_id, last_id], :order => 'id DESC')
    end
  end

  def self.update_alerts(alerts)
    alerts.each do |a|
      a.is_new = false
      a.save
    end
  end

  def self.mark_read(u)
    ActiveRecord::Base.connection.execute('UPDATE alerts SET is_new = 0 WHERE is_new = 1 and user_id = ' + u.id.to_s)
  end

  # def self.create_alert(sender_id,receiver_id,alert_type,item_id)
  #   alert = Alert.new(:sender_id => sender_id,:receiver_id=> receiver_id, :alert_type=>alert_type, :item_id=>item_id, :alert_no => 0,:user_id =>0, :count=> 1)
  #   alert.save
  #   return alert
  # end

  # def update_alert(id)
  #   alert = Alert.find_by_id(id)
  #   count = alert.count
  #   alert.update_attributes(:count => count+1)   
  # end

end
