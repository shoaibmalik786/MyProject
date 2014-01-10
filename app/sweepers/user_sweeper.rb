class UserSweeper < ActionController::Caching::Sweeper
	observe User
  
	def after_save(user)
		expire_cache(user)
	end
  
	def after_destroy(user)
		expire_cache(user)
	end
  
	def expire_cache(user)
		if user.sign_in_count > 0
			expire_fragment "*/items?campaign_page=*"
		end
		if user.sign_in_count == 0
			expire_fragment "*/?signed_in=*"
			expire_fragment "*/modals?*"
		end
	end
end
