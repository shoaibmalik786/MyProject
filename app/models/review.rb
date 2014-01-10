class Review < ActiveRecord::Base
	belongs_to :reviewee, :class_name => "User", :foreign_key=> "reviewee_id"
	belongs_to :reviewer, :class_name => "User", :foreign_key=>"reviewer_id"
	belongs_to :accepted_offer

 	scope :requested_to_remove, :conditions => [ "request_remove_flag = 1" ]

 	def self.submit_review_url
 		return 'http://' + Tradeya::Application.config.action_mailer.default_url_options[:host] + '/submit_user_review/'
 	end
end
