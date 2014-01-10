class CommentSweeper < ActionController::Caching::Sweeper
  observe Comment
  
  def after_save(c)
    expire_cache(c)
  end
  
  def after_destroy(c)
    expire_cache(c)
  end
  
  def expire_cache(c)
    expire_fragment "*/#{c.item_id}/*"
  end
end
