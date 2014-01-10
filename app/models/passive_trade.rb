class PassiveTrade < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :item
  belongs_to :user
  has_one :trade
  has_many :trade_communications
  has_many :transactions

  def trade
  	Trade.joins("INNER JOIN items on items.id = trades.offer_id").where("trades.item_id = #{self.item_id} and items.user_id = #{self.user_id}").first
  end

  def trade_comments
  	self.trade_communications.where("trade_communications.communication_type='COMMENT' and trade_communications.deleted=false")
  end

  def trade_terms
  	self.trade_communications.where("trade_communications.communication_type='TnC' and trade_communications.deleted=false")
  end
end
