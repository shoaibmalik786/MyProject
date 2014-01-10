class InfoAndSetting < ActiveRecord::Base
  include Shared::AttachmentHelper

  has_attachment :home_pg_title_image

  $new_tradeya

  def self.exp_mail_sent_ids(ids = [])
    info = getInfo
    if ids.length == 0 or ids.nil?
      ids = info.exp_mail_sent_ids.split(',')
      ids.each do |i| ids[ids.index(i)] = i.to_i end

      return ids
    else
      info.exp_mail_sent_ids = ids.join(',')
      info.save
    end
  end

  def self.end_mail_sent_ids(ids = [])
    info = getInfo
    if ids.length == 0 or ids.nil?
      ids = info.end_mail_sent_ids.split(',')
      ids.each do |i| ids[ids.index(i)] = i.to_i end

      return ids
    else
      info.end_mail_sent_ids = ids.join(',')
      info.save
    end
  end

  def self.featured_tradeya_mail_sent_ids(ids = [])
    info = getInfo
    if ids.length == 0 or ids.nil?
      ids = info.featured_tradeya_mail_sent_ids.split(',')
      ids.each do |i| ids[ids.index(i)] = i.to_i end

      return ids
    else
      info.featured_tradeya_mail_sent_ids = ids.join(',')
      info.save
    end
  end

  def self.current_tradeyas(ids = [])
    info = getInfo
    if ids.length == 0 or ids.nil?
      ids = info.current_tradeyas.split(',')
      ids.each do |i| ids[ids.index(i)] = i.to_i end

      return ids
    else
      info.current_tradeyas = ids.join(',')
      info.save
    end
  end

  def self.offer_not_rated24h_mail_sent_ids(ids = [])
    info = getInfo
    if ids.length == 0 or ids.nil?
      ids = info.offer_not_rated24h_mail_sent_ids.split(',')
      ids.each do |i| ids[ids.index(i)] = i.to_i end

      return ids
    else
      info.offer_not_rated24h_mail_sent_ids = ids.join(',')
      info.save
    end
  end

  def self.selected_tradeya_mail_sent_ids(ids = [])
    info = getInfo
    if ids.length == 0 or ids.nil?
      ids = info.selected_tradeya_mail_sent_ids.split(',')
      ids.each do |i| ids[ids.index(i)] = i.to_i end

      return ids
    else
      info.selected_tradeya_mail_sent_ids = ids.join(',')
      info.save
    end
  end

  def self.expired_tradeya_mail_sent_ids(ids = [])
    info = getInfo
    if ids.length == 0 or ids.nil?
      ids = info.expired_tradeya_mail_sent_ids.split(',')
      ids.each do |i| ids[ids.index(i)] = i.to_i end

      return ids
    else
      info.expired_tradeya_mail_sent_ids = ids.join(',')
      info.save
    end
  end

  def self.mail_send_to_offerer_ids(ids = [])
    info = getInfo
    if ids.length == 0 or ids.nil?
      ids = info.mail_send_to_offerer_ids.split(',')
      ids.each do |i| ids[ids.index(i)] = i.to_i end

      return ids
    else
      info.mail_send_to_offerer_ids = ids.join(',')
      info.save
    end
  end

  def self.sm_on_trd_live(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_trd_live
    else
      info.sm_on_trd_live = send
      info.save
    end
  end

  def self.sm_on_o_made(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_o_made
    else
      info.sm_on_o_made = send
      info.save
    end
  end

  def self.sm_on_ends_in_24_hour(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_ends_in_24_hour
    else
      info.sm_on_ends_in_24_hour = send
      info.save
    end
  end

  def self.sm_on_rated_ur_i(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_rated_ur_i
    else
      info.sm_on_rated_ur_i = send
      info.save
    end
  end

  def self.sm_on_o_on_ur_o(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_o_on_ur_o
    else
      info.sm_on_o_on_ur_o = send
      info.save
    end
  end

  def self.sm_on_o_higher_than_ur(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_o_higher_than_ur
    else
      info.sm_on_o_higher_than_ur = send
      info.save
    end
  end

  def self.sm_on_24h_offer_not_rated(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_24h_offer_not_rated
    else
      info.sm_on_24h_offer_not_rated = send
      info.save
    end
  end

  def self.sm_on_expired_tradeya(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_expired_tradeya
    else
      info.sm_on_expired_tradeya = send
      info.save
    end
  end

  def self.sm_on_comment_by_other(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_comment_by_other
    else
      info.sm_on_comment_by_other = send
      info.save
    end
  end

  def self.sm_on_comment_by_pub(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_comment_by_pub
    else
      info.sm_on_comment_by_pub = send
      info.save
    end
  end

  def self.sm_on_c(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_c
    else
      info.sm_on_c = send
      info.save
    end
  end

  def self.sm_on_c_pub_copy(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_c_pub_copy
    else
      info.sm_on_c_pub_copy = send
      info.save
    end
  end

  def self.sm_on_c_all(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_c_all
    else
      info.sm_on_c_all = send
      info.save
    end
  end

  def self.sm_on_t_postponed(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_t_postponed
    else
      info.sm_on_t_postponed = send
      info.save
    end
  end

  def self.sm_on_t_resume(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_t_resume
    else
      info.sm_on_t_resume = send
      info.save
    end
  end

  def self.sm_on_acc_deactivated(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_acc_deactivated
    else
      info.sm_on_acc_deactivated = send
      info.save
    end
  end

  def self.sm_on_o_on_t_edited(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_o_on_t_edited
    else
      info.sm_on_o_on_t_edited = send
      info.save
    end
  end

  def self.sm_on_o_on_t_deleted(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_o_on_t_deleted
    else
      info.sm_on_o_on_t_deleted = send
      info.save
    end
  end

  def self.sm_on_o_accepted(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_o_accepted
    else
      info.sm_on_o_accepted = send
      info.save
    end
  end

  def self.sm_on_t_completed(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_t_completed
    else
      info.sm_on_t_completed = send
      info.save
    end
  end

  def self.sm_on_t_postponed_pub(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_t_postponed_pub
    else
      info.sm_on_t_postponed_pub = send
      info.save
    end
  end

  def self.sm_on_t_reactivated(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_t_reactivated
    else
      info.sm_on_t_reactivated = send
      info.save
    end
  end

  def self.sm_on_write_review(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_write_review
    else
      info.sm_on_write_review = send
      info.save
    end
  end

  def self.sm_on_cat_match(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_cat_match
    else
      info.sm_on_cat_match = send
      info.save
    end
  end

  def self.sm_on_person_match(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_person_match
    else
      info.sm_on_person_match = send
      info.save
    end
  end

  def self.sm_on_contest_mail(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_contest_mail
    else
      info.sm_on_contest_mail = send
      info.save
    end
  end

  def self.sm_on_g_upgrade_reminder(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_g_upgrade_reminder
    else
      info.sm_on_g_upgrade_reminder = send
      info.save
    end
  end

  def self.sm_on_g_final_reminder(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_g_final_reminder
    else
      info.sm_on_g_final_reminder = send
      info.save
    end
  end

  def self.sm_on_g_farewell(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_g_farewell
    else
      info.sm_on_g_farewell = send
      info.save
    end
  end

  def self.sm_on_moving_on(send = nil)
    info = getInfo
    if send.nil?
      return info.sm_on_moving_on
    else
      info.sm_on_moving_on = send
      info.save
    end
  end

  def self.tb_token
    info = getInfo
    if info.tb_token.nil?
      info.tb_token = generate_token
      info.tb_token_time = Time.zone.now
      info.save
    elsif ((Time.zone.now.to_time - info.tb_token_time.to_datetime.to_time) / 1.minute).round > 1420
      info.tb_token = generate_token
      info.tb_token_time = Time.zone.now
      info.save
    end

    return info.tb_token
  end

  def self.tb_session_id
    info = getInfo
    if info.tb_session_id.nil?
      info.tb_session_id = g_session_id
      info.save
    end

    return info.tb_session_id
  end

  def self.fb_start_text(send = nil)
    info = getInfo
    if send.nil?
      return info.fb_start_text
    else
      info.fb_start_text = send
      info.save
    end
  end

  def self.home_pg_title_text(send = nil)
    info = getInfo
    if send.nil?
      return info.home_pg_title_text
    else
      info.home_pg_title_text = send
      info.save
    end
  end

  def self.home_pg_title_image
    info = getInfo
    return info.home_pg_title_image
  end

  def self.new_tradeya(send = nil)
    info = getInfo
    if send.nil?
      return info.home_pg_title_text
    else
      info.home_pg_title_text = send
      info.save
    end
  end

  def self.current_category
    info = getInfo
    if info.current_category_updated_at == nil || info.current_category==nil||(Time.zone.now - 4.hours).to_datetime > info.current_category_updated_at 
      return change_current_category
    end
    return info.current_category 
  end 

  def self.current_category_updated_at
    info = getInfo
    return info.current_category_updated_at
  end 

  def self.change_current_category(count = 5)
    info = getInfo
    next_category_id = nil
    #exception - no category exists with 5 active tradeyas, it returns the category with maximum number of active tradeyas
    while next_category_id == nil && count > 0 do
      next_category_id = get_next_category(info.current_category,count)
      count = count-1
    end
    info.current_category = next_category_id
    info.current_category_updated_at = Time.zone.now
    info.save 
    return next_category_id
  end

  def self.current_cat_tradeyas(send = nil)
    info = getInfo
    if send.nil?
      return info.current_cat_tradeyas
    else
      info.current_cat_tradeyas = send
      info.save
    end
  end

  def self.featured_tradeyas(send = nil)
    info = getInfo
    if send.nil?
      return info.featured_tradeyas
    else
      info.featured_tradeyas = send
      info.save
    end
  end
  def self.completed_trades(send = nil)
    info = getInfo
    if send.nil?
      return info.completed_trades
    else
      info.completed_trades = send
      info.save
    end
  end
  def self.newest_tradeyas(send = nil)
    info = getInfo
    if send.nil?
      return info.newest_tradeyas
    else
      info.newest_tradeyas = send
      info.save
    end
  end
  def self.goods_tradeyas(send = nil)
    info = getInfo
    if send.nil?
      return info.goods_tradeyas
    else
      info.goods_tradeyas = send
      info.save
    end
  end
  def self.services_tradeyas(send = nil)
    info = getInfo
    if send.nil?
      return info.services_tradeyas
    else
      info.services_tradeyas = send
      info.save
    end
  end


:private
  def self.getInfo
    info = InfoAndSetting.first
    if info.nil?
      info = InfoAndSetting.new
    end
    return info
  end

  def self.generate_token
    opentok = OpenTok::OpenTokSDK.new OPENTOK_API_KEY, OPENTOK_API_SECRET
    token = opentok.generate_token :session_id => InfoAndSetting.tb_session_id, :role => OpenTok::RoleConstants::MODERATOR
    return token
  end

  def self.g_session_id
    opentok = OpenTok::OpenTokSDK.new OPENTOK_API_KEY, OPENTOK_API_SECRET
    session_id = opentok.create_session(SERVER_LOCATION)
    return session_id
  end

  def self.get_next_category(current_category_id = nil, count = 5)
    # looks for distict 5 users, purpose : not to repeat a user or home page
    categories = Category.find_by_sql("SELECT category_id from items where " + Item.get_query_for_active_tradeyas + " group by category_id having count(distinct user_id) >= " + count.to_s + " order by category_id")
    # else look for distinct 5 items
    if categories.nil? or categories.size < 1
      categories = Category.find_by_sql("SELECT category_id from items where " + Item.get_query_for_active_tradeyas + " group by category_id having count(*) >= " + count.to_s + " order by category_id")
    end
    c = 0
    next_category_id = nil
    if current_category_id == nil
      next_category_id = categories.first.category_id unless categories.size < 1
    else
      for c in (0..categories.size - 1)
        if categories[c].category_id > current_category_id 
          next_category_id = categories[c].category_id
          break
        end
       end
      #current_category has the last category in the list, then first category should be made next_category
      next_category_id = categories.first.category_id if next_category_id == nil && categories.size > 0
    end
    return next_category_id
  end

end
