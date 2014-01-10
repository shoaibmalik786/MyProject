class ItemPhoto < ActiveRecord::Base
  include Shared::AttachmentHelper
  scope :by_main_photo, order("main_photo DESC")
  belongs_to :item

  has_attachment :photo,
  :styles => { :original => '5000x5000>',
    :large => "800x>",
    :crop_large => "318X238>",
    :medium => "225x>",
    :thumb => "83X75"},
    # :crop_large => "340x256>",
    # :large => "340x256#",
    # :medium => "272x205#",
    # :medium_mail => "186x140#",
    # :thumb => "136x102#",
    # :small => "72x52#" },
  :convert_options => { :all => '-auto-orient' },
  :processors => [:cropper]

  validates_attachment_presence :photo
  validates_attachment_size :photo, :less_than => 15.megabytes
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png', 'image/jpg', 'image/gif','image/pjpeg', 'image/x-png']

  # attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :reprocess_photo, :if => :cropping?
  # after_post_process :save_image_dimensions
  after_save :isImgAutoWidth

  def save_image_dimensions
    geo = Paperclip::Geometry.from_file(self.photo.queued_for_write[:original])
    self.width = geo.width
    self.height = geo.height
    self.save
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def photo_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(self.photo.to_file(style))
  end

  def photo_from_url(url)
    self.photo = open(url)
  end

  def isImgAutoWidth
    if self.height == 0 and self.width == 0 and self.photo_file_name != nil
      begin
        geo = Paperclip::Geometry.from_file(self.photo.to_file(:original))
        self.height = geo.height
        self.width = geo.width
        self.save
      rescue StandardError => e
        puts "unable to find image for item.: " + self.id.to_s
      end
    end

    r = 0
    if self.height > 0
      r = self.width.to_f / self.height.to_f
    end

    if r >= 1.3
      return false
    else
      return true
    end
  end

  private

  def reprocess_photo
    photo.reprocess!
  end
end
