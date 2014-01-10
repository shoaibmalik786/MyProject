class Like < ActiveRecord::Base
	include PublicActivity::Common

  belongs_to :user
  belongs_to :item
end
