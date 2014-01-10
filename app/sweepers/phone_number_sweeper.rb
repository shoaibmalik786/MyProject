class PhoneNumberSweeper < ActionController::Caching::Sweeper
  observe PhoneNumber
  
  def after_save(pn)
    expire_cache(pn)
  end
  
  def after_destroy(pn)
    expire_cache(pn)
  end
  
  def expire_cache(pn)
    # expire_fragment "*/items?campaign_page=*"
    expire_fragment "*/?signed_in=*"
    expire_fragment "*/modals?*"
  end
end
