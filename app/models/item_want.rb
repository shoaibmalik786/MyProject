class ItemWant < ActiveRecord::Base
  belongs_to :item
  belongs_to :user
  belongs_to :category

  attr_accessor :status

  after_initialize :init

  class << self; attr_accessor :default_title end
  @default_title = 'Write a title for what you want here...'

  def init
    self.title ||= ItemWant.default_title
  end

  def category_title
    return ((category.nil?) ? 'Service - Technology' : category.title)
  end
end
