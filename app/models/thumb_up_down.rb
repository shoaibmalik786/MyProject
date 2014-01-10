class ThumbUpDown < ActiveRecord::Base
	belongs_to :user

	scope :thumbs_up, :conditions => ["thumbs_up = true"]
	scope :thumbs_down, :conditions => ["thumbs_up = false"] 
	scope :feedback_received, :conditions => ["thumbs_up IS NOT NULL"]
	
 	def self.up_down_url(v, t)
 		return 'http://' + Tradeya::Application.config.action_mailer.default_url_options[:host] + '/thumb_up_down/' + v + '/' + t
 	end

 	def self.total_feedback
 		return thumbs_up.count + thumbs_down.count
 	end

 	def self.thumbs_up_percent
 		return ((thumbs_up.count * 100.0)/total_feedback).round(2)
 	end

 	def self.thumbs_down_percent
 		return ((thumbs_down.count * 100.0)/total_feedback).round(2)
 	end
end
