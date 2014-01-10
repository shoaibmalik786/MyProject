class Transaction < ActiveRecord::Base
  attr_accessible :charge_id, :ship_charge, :trade_id, :trans_charge, :user_id, :address_id, :weight, :height, :length, :width, :ship_notes, :ship_type_name, :ship_type_code, :card_id, :transaction_status

  include Shared::AttachmentHelper
  belongs_to :user
  belongs_to :passive_trade
  belongs_to :trade
  belongs_to :address

  has_attachment :label

  validates_attachment_content_type :label, :content_type => ['image/jpeg', 'image/png', 'image/jpg', 'image/gif','image/pjpeg', 'image/x-png']

  # TODO: Need to add validations
end
