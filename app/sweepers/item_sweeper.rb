class ItemSweeper < ActionController::Caching::Sweeper
  observe Item
  
  def after_save(item)
    expire_cache(item)
  end
  
  def after_destroy(item)
    expire_cache(item)
  end
  
  def expire_cache(item)
    expire_fragment "*/items?campaign_page=false&signed_in=*"
    expire_fragment "*/items?campaign_page=true&signed_in=*"
    expire_fragment "*/items?campaign_page=*newest*"
    expire_fragment "*/items?campaign_page=*all*"
    expire_fragment "*/items?campaign_page=*featured*"
    expire_fragment "*/items?campaign_page=*completed*"
    expire_fragment "*/items?campaign_page=*#{item.category_id}*"

    expire_fragment "*/#{item.id}/*"
    expire_fragment "trd_pg_meta_tags_#{item.id}"
    expire_fragment "trd_timer_#{item.id}"

    # expire_fragment %r{/items\?signed_in=}
    # expire_fragment %r{/items\?category=}
  end
end
