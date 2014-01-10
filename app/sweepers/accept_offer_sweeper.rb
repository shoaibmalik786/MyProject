class AcceptOfferSweeper < ActionController::Caching::Sweeper
  observe AcceptedOffer
  
  def after_save(accept_offer)
    expire_cache(accept_offer)
  end
  
  def after_destroy(accept_offer)
    expire_cache(accept_offer)
  end
  
  def expire_cache(accept_offer)
    # expire_fragment "*/items?campaign_page=*"
    expire_fragment "*/items?campaign_page=false&signed_in=*"
    expire_fragment "*/items?campaign_page=true&signed_in=*"
    expire_fragment "*/items?campaign_page=*newest*"
    expire_fragment "*/items?campaign_page=*featured*"
    expire_fragment "*/items?campaign_page=*#{accept_offer.trade.item.category_id}*"

    expire_fragment "*/#{accept_offer.trade.item_id}/*"
  end
end
