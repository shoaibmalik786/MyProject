require 'open-uri'  

class FireTrackingPixelJob
  @queue = :tracking

  def self.perform(user_id, event)
    user = User.find_by_id user_id    
    tracker = user.tracking_info
    if tracker
      case event
      when 'signup'
        pixel_url = "http://sboffers.swagbucks.com/SPc0?transaction_id=#{tracker.sbx_code}"
      when 'post'
        pixel_url = "http://sboffers.swagbucks.com/GPc6?transaction_id=#{tracker.sbx_code}"
      end
      open(pixel_url)      
    end
  end

end
