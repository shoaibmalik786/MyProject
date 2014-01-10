class Comment < ActiveRecord::Base
	include PublicActivity::Common
	has_many :replies, :class_name => "Comment",
           :foreign_key => "parent_comment_id", dependent: :destroy
  belongs_to :parent_comment, :class_name => "Comment",
             :foreign_key => "parent_comment_id"
  belongs_to :user
  belongs_to :item
  scope :active, :conditions => {:deleted => false}

  def self.item_comments(item_id)
    return Comment.find(:all, :conditions => {:item_id => item_id, :deleted => false, :offer_id => nil}, :order => 'created_at')
  end
end
