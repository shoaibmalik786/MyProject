require "open-uri"

class ItemVideo < ActiveRecord::Base
  include Shared::AttachmentHelper

  belongs_to :item

  has_attachment :video
  
  validates_attachment_content_type :video, :content_type=>['video/3gpp','video/x-msvideo', 'video/x-ms-asf', 'video/quicktime','video/mpeg','video/mp4','video/x-ms-wmv','video/flv','video/x-flv','application/mp4'], :message => "invalid."
  validates_attachment_size :video, :less_than => 1.gigabytes, :message => 'too large.'
  
  
  def video_from_url(url)
    self.video = open(url)
  end
end
