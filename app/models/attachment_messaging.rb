class AttachmentMessaging < ActiveRecord::Base

  belongs_to :notification
  attr_accessible :notif_id
  has_attached_file :attachment
end
