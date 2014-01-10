class Want < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :user
  belongs_to :item
end
