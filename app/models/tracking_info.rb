class TrackingInfo < ActiveRecord::Base
  attr_accessible :user_id, :sbx_code, :utm_campaign, :utm_source,
    :utm_medium, :utm_content, :term
  belongs_to :user

  validates :user_id, presence: true
end
