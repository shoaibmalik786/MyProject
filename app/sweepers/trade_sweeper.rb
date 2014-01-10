class TradeSweeper < ActionController::Caching::Sweeper
  observe Trade
  
  def after_save(t)
    expire_cache(t)
  end
  
  def after_destroy(t)
    expire_cache(t)
  end
  
  def expire_cache(t)
    expire_fragment "*/#{t.item_id}/*"
  end
end
