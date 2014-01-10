namespace :db do
  desc "for goods_str,services_str,interests_str and tradeya_count to improve performance of user profile"
  task :update_user_columns => :environment do
  	users = User.all
  	if users != nil
  		users.each do |user|
  		   	user.update_attribute("goods_str",user.goods)
  		   	user.update_attribute("services_str",user.services)
  		   	user.update_attribute("interests_str",user.interests)
  		   	user.update_attribute("tradeya_count",user.get_user_live_tradeya_count)
  	 	end
  	end
  end
end
