class UserPhotoSweeper < ActionController::Caching::Sweeper
  observe UserPhoto
  
  def after_save(user_photo)
    expire_cache(user_photo)
  end
  
  def after_destroy(user_photo)
    expire_cache(user_photo)
  end
  
  def expire_cache(user_photo)
    expire_fragment "*/items?campaign_page=*"
    expire_fragment "*/?signed_in=*"
    expire_fragment "*/modals?*"
  end
end
