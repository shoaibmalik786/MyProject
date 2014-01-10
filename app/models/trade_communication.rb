class TradeCommunication < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :passive_trade
  belongs_to :trade
  belongs_to :owner, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
end
