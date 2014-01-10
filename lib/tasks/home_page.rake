desc "Generate data for home page such that Users are not repeated"
namespace :home_page do
# rake setup categories to db.
  task :generate_home_page_data => [:environment] do
    user_ids = []
    user_ids_str = ''
    item_ids = []
    item_ids_str = ''

    # Current Category section
    current_cat_tods = Item.set_current_category_tradeyas(true)
    current_cat_tods.each do |tod|
      user_ids[user_ids.count] = tod.user_id
      user_ids_str += ((user_ids_str.length > 0) ? ',' + tod.user_id.to_s : tod.user_id.to_s )
      item_ids[item_ids.count] = tod.id
      item_ids_str += ((item_ids_str.length > 0) ? ',' + tod.id.to_s : tod.id.to_s )
    end
    if item_ids.length < 5
      current_cat_tods = Item.set_current_category_tradeyas
      current_cat_tods.each  do |tod|
        if item_ids.length == 5 then break end
        if item_ids.index(tod.id).nil?
          user_ids[user_ids.count] = tod.user_id
          user_ids_str += ((user_ids_str.length > 0) ? ',' + tod.user_id.to_s : tod.user_id.to_s )
          item_ids[item_ids.count] = tod.id
          item_ids_str += ((item_ids_str.length > 0) ? ',' + tod.id.to_s : tod.id.to_s )
        end
      end
    end
    puts 'Category - ' + item_ids.to_s
    # set this item_id_str in a table in InfoAndSettings
    InfoAndSetting.current_cat_tradeyas(item_ids_str)


    # Featured Category section
    featured_tods = Item.featured_tradeyas(5,true,nil,user_ids)
    item_ids = []
    item_ids_str = ''
    featured_tods.each do |tod|
      user_ids[user_ids.count] = tod.user_id
      user_ids_str += (',' + tod.user_id.to_s)
      item_ids[item_ids.count] = tod.id
      item_ids_str += ((item_ids_str.length > 0) ? ',' + tod.id.to_s : tod.id.to_s )
    end
    puts 'Featured - ' + item_ids.to_s
    # set this item_id_str in a column in InfoAndSettings
    InfoAndSetting.featured_tradeyas(item_ids_str)

    # recently Completed Trades
    rc_trades = AcceptedOffer.recent_completed_tradeyas
    trades_id = []
    trades_id_str = ''
    rc_trades.each do |trade|
      if trades_id.length == 5 then break end
      item_uid = trade.item.user_id
      offer_uid = trade.offer.user_id
      if user_ids.index(item_uid).nil? and user_ids.index(offer_uid).nil?
        trades_id[trades_id.count] = trade.id
        trades_id_str += ((trades_id_str.length > 0) ? ',' + trade.id.to_s : trade.id.to_s)
        user_ids[user_ids.count] = item_uid
        user_ids[user_ids.count] = offer_uid
        user_ids_str += ',' + item_uid.to_s + ',' + offer_uid.to_s
      end
    end
    if trades_id.length < 5
      rc_trades.each do |trade|
        if trades_id.length == 5 then break end
        item_uid = trade.item.user_id
        offer_uid = trade.offer.user_id
        if (user_ids.index(item_uid).nil? or user_ids.index(offer_uid).nil?) and trades_id.index(trade.id).nil?
          trades_id[trades_id.count] = trade.id
          trades_id_str += ((trades_id_str.length > 0) ? ',' + trade.id.to_s : trade.id.to_s)
          user_ids[user_ids.count] = item_uid
          user_ids[user_ids.count] = offer_uid
          user_ids_str += ',' + item_uid.to_s + ',' + offer_uid.to_s
        end
      end
    end
    if trades_id.length < 5
      rc_trades.each do |trade|
        if trades_id.length == 5
          break
        elsif trades_id.index(trade.id).nil?
          trades_id[trades_id.count] = trade.id
          trades_id_str += ((trades_id_str.length > 0) ? ',' + trade.id.to_s : trade.id.to_s)
        end
      end
    end
    # set these values of trades_id in Info And Setting table
    puts 'Trades - ' + trades_id.to_s
    InfoAndSetting.completed_trades(trades_id_str)

    # newest category
    newest_tods = Item.get_newest_tradeyas(nil,nil,user_ids_str)
    item_ids = []
    item_ids_str = ''
    newest_tods.each do |tod|
      if item_ids.length == 5 then break end
      if user_ids.index(tod.user_id).nil?
        user_ids[user_ids.count] = tod.user_id
        user_ids_str += (',' + tod.user_id.to_s)
        item_ids[item_ids.count] = tod.id
        item_ids_str += ((item_ids_str.length > 0) ? ',' + tod.id.to_s : tod.id.to_s )
      end
    end
    if item_ids.length < 5
      newest_tods = Item.get_newest_tradeyas
      newest_tods.each do |tod|
        if item_ids.length == 5 then break end
        if item_ids.index(tod.id).nil?
          item_ids[item_ids.count] = tod.id
          item_ids_str += ((item_ids_str.length > 0) ? ',' + tod.id.to_s : tod.id.to_s )
        end
      end
    end
    puts "Newest - " + item_ids.to_s
    InfoAndSetting.newest_tradeyas(item_ids_str)

    # goods category
    goods_tods = Item.goods_tradeyas(nil,false,user_ids_str)
    item_ids = []
    item_ids_str = ''
    goods_tods.each do |tod|
      if item_ids.length == 5 then break end
      if user_ids.index(tod.user_id).nil?
        user_ids[user_ids.count] = tod.user_id
        user_ids_str += (',' + tod.user_id.to_s)
        item_ids[item_ids.count] = tod.id
        item_ids_str += ((item_ids_str.length > 0) ? ',' + tod.id.to_s : tod.id.to_s )
      end
    end
    if item_ids.length < 5
      goods_tods = Item.goods_tradeyas
      goods_tods.each do |tod|
        if item_ids.length == 5 then break end
        if item_ids.index(tod.id).nil?
          item_ids[item_ids.count] = tod.id
          item_ids_str += ((item_ids_str.length > 0) ? ',' + tod.id.to_s : tod.id.to_s )
        end
      end
    end
    puts "goods - " + item_ids.to_s
    InfoAndSetting.goods_tradeyas(item_ids_str)


    # services category
    services_tods = Item.services_tradeyas(nil,false,user_ids_str)
    item_ids = []
    item_ids_str = ''
    services_tods.each do |tod|
      if item_ids.length == 5 then break end
      if user_ids.index(tod.user_id).nil?
        user_ids[user_ids.count] = tod.user_id
        user_ids_str += (',' + tod.user_id.to_s)
        item_ids[item_ids.count] = tod.id
        item_ids_str += ((item_ids_str.length > 0) ? ',' + tod.id.to_s : tod.id.to_s )
      end
    end
    if item_ids.length < 5
      services_tods = Item.services_tradeyas
      services_tods.each do |tod|
        if item_ids.length == 5 then break end
        if item_ids.index(tod.id).nil?
          item_ids[item_ids.count] = tod.id
          item_ids_str += ((item_ids_str.length > 0) ? ',' + tod.id.to_s : tod.id.to_s )
        end
      end
    end
    puts "services - " + item_ids.to_s
    InfoAndSetting.services_tradeyas(item_ids_str)

    system("curl 'http://#{DOMAIN}/clear_home_cache'")
  end
end
