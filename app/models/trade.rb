class Trade < ActiveRecord::Base
  belongs_to :item
  belongs_to :offer, :class_name => "Item"
  has_one :accepted_offer, :dependent => :destroy
  has_many :alerts, :dependent => :destroy
  has_many :comments, :foreign_key => "offer_id", :dependent => :destroy
  has_many :transactions
  belongs_to :passive_trade
  has_many :trade_communications

  scope :offers, :conditions => [ "id NOT IN (SELECT trade_id AS id FROM accepted_offers)" ]
  scope :traded, :conditions => [ "trades.id IN (SELECT trade_id AS id FROM accepted_offers)" ]
  scope :activeOffers, :conditions => [ "trades.id NOT IN (SELECT trade_id AS id FROM accepted_offers) and trades.status = 'ACTIVE' " ]
  scope :order_by_latest, :order => "trades.created_at desc"
  scope :order_by_oldest, :conditions => "trades.created_at asc"
  scope :active, :conditions => "status = 'ACTIVE'"
  scope :with_live_item, joins("inner join items as tradeya on tradeya.id = trades.item_id").where("tradeya.status = 'LIVE' and tradeya.quantity > 0")
  scope :with_live_offer, joins("inner join items as offers on offers.id = trades.offer_id").where("offers.status = 'LIVE' and offers.quantity > 0")
  # scope :by_user, lambda { |u| }


  # ajaxful_rateable :stars => 5

  ACTIVE_OFFERS_BY_USER = "select trades.* from trades left join items as offer on trades.offer_id = offer.id left join items as tradeya on trades.item_id = tradeya.id where offer.user_id = USER_ID and ((tradeya.status = 'LIVE' OR tradeya.status IS NULL)) and trades.id NOT IN (select trade_id from accepted_offers) and (trades.status IS NULL or trades.status != 'DELETED') order by trades.id desc"
  COMPLETED_OFFERS_BY_USER = "select trades.* from trades left join items as offer on trades.offer_id = offer.id where offer.user_id = USER_ID and trades.id IN (select trade_id from accepted_offers) and (trades.status IS NULL or trades.status != 'DELETED') order by trades.id desc"
  PAST_OFFERS_BY_USER = "select trades.* from trades left join items as offer on trades.offer_id = offer.id left join items as tradeya on trades.item_id = tradeya.id where offer.user_id = USER_ID and ((tradeya.status = 'EXPIRED' or tradeya.status = 'COMPLETED' or tradeya.status = 'POSTPONED') and (tradeya.status != 'DELETED')) and trades.id NOT IN (select trade_id from accepted_offers) and (trades.status IS NULL or trades.status != 'DELETED') order by trades.id desc"


  def title
    return item.title + ' VS ' + offer.title
  end

  def self.total_offers(item_id)
    return self.find_by_sql("select count(*) as offers from trades where item_id = #{item_id}")[0].offers
  end

  def offer_deleted?
    if offer == nil then return true elsif status == "DELETED" then return true else return false end
  end

  def rejected?
    return ((status and status == 'REJECTED')? true : false)
  end

  def active?
    # this can be eventually changed to only a check on status == 'ACTIVE'
    return Trade.activeOffers.where(:id => self.id).present?
  end

  def self.get_user_current_offers(user_id)
    # today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    query = ACTIVE_OFFERS_BY_USER.sub("USER_ID",user_id.to_s)
    # query = query.sub("TODAY",today)
    tods =  find_by_sql(query)
    return User.filter_by_user(tods)
  end

  def self.get_user_successful_offers(user_id)
    query = COMPLETED_OFFERS_BY_USER.sub("USER_ID",user_id.to_s)
    tods =  find_by_sql(query)
    return User.filter_by_user(tods)
  end

  def self.get_user_past_offers(user_id)
    # today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    query = PAST_OFFERS_BY_USER.sub("USER_ID",user_id.to_s)
    # query = query.sub("TODAY",today)
    tods =  find_by_sql(query)
    return User.filter_by_user(tods)
  end

  def private_conversations
    return self.comments.where(:deleted => false)
  end

  def trade_comments
    self.trade_communications.where("trade_communications.communication_type='COMMENT' and trade_communications.deleted=false")
  end

  def trade_terms
    self.trade_communications.where("trade_communications.communication_type='TnC' and trade_communications.deleted=false")
  end

end
