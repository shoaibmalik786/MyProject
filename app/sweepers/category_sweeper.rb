class CategorySweeper < ActionController::Caching::Sweeper
  observe Category
  
  def after_save(category)
    expire_cache(category)
  end
  
  def after_destroy(category)
    expire_cache(category)
  end
  
  def expire_cache(category)
    expire_fragment('header_left')
    expire_fragment('header_right')
  end
end
