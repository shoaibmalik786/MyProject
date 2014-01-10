class AuthenticationSweeper < ActionController::Caching::Sweeper
	observe Authentication

	def after_save(auth)
		expire_cache(auth)
	end

	def after_destroy(auth)
		expire_cache(auth)
	end

	def expire_cache(auth)
	    # expire_fragment "*/items?campaign_page=*"
	    expire_fragment "*/?signed_in=*"
	    expire_fragment "*/modals?*"
	end
end
