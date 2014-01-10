class ReviewSweeper < ActionController::Caching::Sweeper
  observe Review
  
  def after_save(r)
    expire_cache(r)
  end
  
  def after_destroy(r)
    expire_cache(r)
  end
  
  def expire_cache(r)
  	# r.reviewer.items.each do |i|
  	# 	if i.tod
		 #    expire_fragment "*/#{i.id}/*"
		 #  else
			#   i.offers.each do |o|
			#     expire_fragment "*/#{o.item_id}/*"
			#   end
		 #  end
	  # end
  end
end
