class ChargeCard < ActiveRecord::Base
  attr_accessible :card_id, :cust_id, :last_4, :provider, :user_id, :card_type, :exp_month, :exp_year, :current
  belongs_to :user
end
