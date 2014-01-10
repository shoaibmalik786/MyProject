class UserPhoto < ActiveRecord::Base
  include Shared::AttachmentHelper
  require "open-uri"
  scope :by_latest, order("created_at DESC")
  scope :by_main_photo, order("user_main_photo DESC")
  belongs_to :user

  has_attachment :photo,
  :styles => {:original => '2500x2500>',
    :crop_large => "300x300>",
    # :edited => "630x440#",
    :large => "500x500#",
    :medium => "200x200#",
    :thumb => "100x100#",
    :small_80x80 => "80x80#",
    :small => "50x50#" },
  :convert_options => { :all => '-auto-orient' },
  :processors => [:cropper]

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :reprocess_photo, :if => :cropping?

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def photo_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(self.photo.to_file(style))
  end

  def photo_from_url(url)
    self.photo = open(url)
    # self.photo = URI.parse(url)
  end

  private

    def reprocess_photo
      photo.reprocess!
    end
end
