# This rake file send email to offerers.
# They can be executed as follows:

desc "Send email to offerers."
namespace :alert do
# rake Send email to offerers.
  task :send_mail2offerer => [:environment] do
    begin
      puts Time.now.to_s + " - Task started."
      tod_ofr = []
      new_trades = []
      old_trades = []

      if InfoAndSetting.sm_on_o_on_ur_o
        tods = Item.find(:all, :conditions => {:tod => true, :status => "LIVE"})
        tods.each do |tod|
          new_trades = tod.trades.find(:all, :conditions => "mail_sent_offer_ofr_on_ur_ofr = false AND status != 'DELETED'")
          old_trades = tod.trades.find(:all, :conditions => "mail_sent_offer_ofr_on_ur_ofr = true AND status != 'DELETED'")
          new_trades.each do |t|
            old_trades.each do |ot|
              if ot.accepted_offer.nil?
                EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_OFFER_MADE_ON_YOUR_OFFER, ot.offer.user.id, {:trade_id => ot.id})
                if tod_ofr.index(tod.id).nil?
                  tod_ofr[tod_ofr.count] = tod.id
                end
              end
            end
            old_trades[old_trades.count] = t
            t.update_attribute('mail_sent_offer_ofr_on_ur_ofr',true)
          end
        end
      end
      puts "Offer received on your offer mail sent for TradeYas - " + tod_ofr.to_s
      puts Time.now.to_s + " - Task completed."
    rescue StandardError => e 
      puts Time.now.to_s + " - Exception occured - " + e.message + "\n" + e.backtrace.to_s
      e = nil
    end
  end

# rake Send mail to publisher that ur offer going to expire
  task :send_mail2publisher => [:environment] do
    begin
      puts Time.now.to_s + " - Task started."
      # tod_exp = []  # Expired Tradeyas
      # tod_comp = [] # Completed Tradeyas
      # tod_12 = []   # Ending in 12 hours
      # tod_24 = []   # Ending in 24 hours 
      # tod_ofr = []  # Rate Offers
      # if InfoAndSetting.sm_on_ends_in_24_hour
      #   tods = Item.find(:all, :conditions => {:tod => true, :status => "LIVE"})
      #   ct = Time.now

      #   clear_cache = false

      #   tods.each do |tod|
      #     if ((tod.exp_date.to_time - ct.to_time) / 1.hour) <= 0 and tod.accepted_trades.count == 0
      #       # Suppressed calls for expired tradeyas 

      #       # tod.status = "EXPIRED"
      #       # tod.save
      #       # clear_cache = true

      #       # tod.trades.each do |trd|
      #       #   if !trd.offer_deleted?
      #       #     Alert.add_2_alert_q(ALERT_TYPE_OFFER, TRADEYA_EXPIRED, trd.offer.user.id, trd.item.id, trd.id)
      #       #     Alert.add_2_alert_q(ALERT_TYPE_OFFER, OFFER_NOT_ACCEPTED, trd.offer.user.id, trd.item.id, trd.id)
      #       #   end
      #       # end
            
      #       # if tod.user.notify_tradeya_over then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_EXPIRE, tod.user.id, {:item_id => tod.id}) end
      #       # tod_exp[tod_exp.count] = tod.id
      #       # system("curl 'http://#{DOMAIN}/clear_item_cache?id=#{tod.id}'")

      #       # Suppressed calls for completed tradeyas
      #     elsif ((tod.exp_date.to_time - ct.to_time) / 1.hour) <= 0 and tod.accepted_trades.count > 0
      #       # tod.status = "COMPLETED"
      #       # tod.save
      #       # clear_cache = true

      #       # tod.trades.each do |trd|
      #       #   if trd.accepted_offer.nil? and !trd.offer_deleted?
      #       #     Alert.add_2_alert_q(ALERT_TYPE_OFFER, OFFER_NOT_ACCEPTED, trd.offer.user.id, trd.item.id, trd.id)
      #       #   end
      #       # end
      #       # if tod.user.notify_tradeya_complete then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_COMPLETED, tod.user.id, {:item_id => tod.id}) end  
      #       # tod_comp[tod_comp.count] = tod.id
      #       # system("curl 'http://#{DOMAIN}/clear_item_cache?id=#{tod.id}'")
          
      #     # elsif ((tod.exp_date.to_time - ct.to_time) / 1.hour) <= 12 and not tod.is_mail_sent_12
      #     #   Alert.add_2_alert_q(ALERT_TYPE_TRADEYA, TRADEYA_ENDING_IN_12_HOUR, tod.user.id, tod.id)
      #     #   tod.update_attribute('is_mail_sent_12',true)
      #     #   tod_12[tod_12.count] = tod.id
          
      #     # elsif ((tod.exp_date.to_time - ct.to_time) / 1.hour) <= 24 and not tod.is_mail_sent_24
      #     #   if tod.user.notify_tradeya_timer then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_OFFER_ENDS_IN_24_HOUR, tod.user.id, {:item_id => tod.id}) end
      #     #   Alert.add_2_alert_q(ALERT_TYPE_TRADEYA, TRADEYA_EXPIRE_IN_24_HOUR, tod.user.id, tod.id)
      #     #   tod.update_attribute('is_mail_sent_24',true)
      #     #   tod_24[tod_24.count] = tod.id
      #     end

      #     if InfoAndSetting.sm_on_24h_offer_not_rated
      #       tod.trades.each do |t|
      #         freq = (t.rate_offer_mail_count == 0 ? 24 : 48)
      #         if (((ct.to_time - t.offer.created_at.to_time) / 1.hour) / freq) > t.rate_offer_mail_count and t.rate_offer_mail_count < 5 and t.rating_average.to_f == 0.0 and tod_ofr.index(t.id).nil? and t.status == "ACTIVE" #and !t.mail_sent_pub_rateoffer
      #           EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_RATE_OFFER, t.item.user.id, {:trade_id => t.id})
      #           tod_ofr[tod_ofr.count] = t.id
      #           t.update_attribute("rate_offer_mail_count", (t.rate_offer_mail_count + 1))
      #           # t.update_attribute("mail_sent_pub_rateoffer",true)
      #         end
      #       end
      #     end
      #   end
      #   # if clear_cache then system("curl 'http://#{DOMAIN}/clear_item_cache'") end
      # end

      # puts "Expired Tradeyas alerts/mails sent for TradeYas - " + tod_exp.to_s
      # puts "Completed Tradeyas alerts/mails sent for TradeYas - " + tod_comp.to_s
      # puts "12 hours remaining alerts added for TradeYas - " + tod_12.to_s
      # puts "24 hours remaining alerts/mails sent for TradeYas - " + tod_24.to_s 
      # puts "Rate your offers mail sent for TradeYas - " + tod_ofr.to_s

      # for ALERTS your tradeya being featured FEATURED today
      trds = []
      counter = 0
      featured_tradeyas = []
      featured_tradeyas = FeaturedTradeya.current_featured_list
      featured_tradeyas.each do |ft|
        if !ft.mail_sent_pub
          tod = ft.item
          if tod.live? and trds.index(tod.id).nil?
            # Alert.add_2_alert_q(ALERT_TYPE_TRADEYA, TRADEYA_FEATURED, tod.user.id,tod.id)
            trds[counter] = tod.id
            counter += 1
          end
          ft.update_attribute("mail_sent_pub",true)
        end
      end
      puts "Featured TradeYas Alerts sent to - " + trds.to_s

      puts Time.now.to_s + " - Task completed."
    rescue StandardError => e 
      puts Time.now.to_s + " - Exception occured - " + e.message + "\n" + e.backtrace.to_s
      e = nil
    end
  end
end