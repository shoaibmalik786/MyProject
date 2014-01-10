class ItemsController < ApplicationController
  require 'RMagick'
  include Magick
  before_filter :authenticate_user!
  before_filter :current_location
  # before_filter :require_user

  cache_sweeper :item_sweeper, :only => [:create, :update, :destroy, :postpone_trade, :complete_trade, :clear_cache]
  cache_sweeper :trade_sweeper, :only => [:create, :update]
  caches_action :new, :layout => false, :cache_path => Proc.new { |c|
    c.params[:signed_in] = (not current_user.nil?)

    rfr = ""
    if request.referer.present?
      rfr = request.referer
      rfr = rfr.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
      rfr = rfr.encode!('UTF-8', 'UTF-16')
      rfr = rfr.gsub(/[^0-9A-Za-z]/, '')
    end
    c.params[:referer] = rfr
    c.params
  }
  caches_action :index, :layout => false, :cache_path => Proc.new { |c| c.params[:signed_in] = (not current_user.nil?); c.params[:zip_code] = ((current_user.nil? || current_user.zip.nil?)? "" : current_user.zip); c.params[:campaign_page] = (not request.fullpath.index('/browser-campn-1-13').nil?); c.params;}, if: lambda { |c| (c.params[:category] != 'myoffers' and c.params[:category] != 'mytrades' and c.params[:page].nil?)}
  # caches_action :browse_all, :layout => false, :cache_path => Proc.new { |c| c.params[:signed_in] = (not current_user.nil?); c.params}, if: lambda { |c| (c.params[:category] != 'myoffers' and c.params[:category] != 'mytrades' and c.params[:page].nil?)}
  caches_action :namelink, :layout => false, :cache_path => Proc.new { |c|
    c.params[:signed_in] = (not current_user.nil?)
    it = Item.find(params[:id], :select => "user_id")
    c.params[:pub] = ((not current_user.nil? and it.user_id == current_user.id) ? "true" : ((not current_user.nil? and current_user.offerer?(params[:id])) ? "offerer" : "false"))
    c.params[:offerer] = ((current_user.present? and current_user.offerer?(params[:id]))? current_user.id : "false")
    # c.params[:offer_form] = ab_test("make_offer_form", "form", "new_make_offer")
    c.params
  }, if: lambda { |c| (c.params[:category] != 'myoffers' and c.params[:category] != 'mytrades' and c.params[:page].nil?)}

  # GET /items
  # GET /items.json
  def index
    # session[:have_page] = url_for(params.except(:page))
    within = nil
    if session[:within].present? then within = session[:within].to_i end
    begin
      #if category params present (except all) and search not present
      if params[:category].present? and !params[:category].blank? and params[:category] != 'all' and !params[:search].present?
        @results_for = Category.find_by_id(params[:category]).name.titleize
        if params[:sort_by].present? and (params[:sort_by] == "distance" or params[:sort_by] == "most offered")
          #sort by distance or most offered
          search_result = Item.item_search(nil, params[:category], params[:sort_by],nil,nil, params[:page], session[:user_ll], within, nil)
        elsif params[:sort_by].present? and params[:sort_by] == "friends"
          #friends items
          search_result = Item.item_search(nil, params[:category], params[:sort_by],nil,nil, params[:page], session[:user_ll], within, nil, current_user.id)
        else
          #sort by Most Recent
          search_result = Item.item_search(nil, params[:category], nil,nil,nil, params[:page], session[:user_ll], within, nil)
        end
        if search_result.present?
          @items = search_result.results
          # @distance = Item.calculate_distance(@items,session[:user_ll])
          @i_total = search_result.total
        else
          @items =[]
          @i_total = 0
        end
        #else if search params are present, then search based on search text
      elsif params[:search].present? and !params[:category].present?
        @results_for = params[:search]
        if params[:sort_by].present? and (params[:sort_by] == "distance" or params[:sort_by] == "most offered")
          #sort by distance or most offered
          search_result = Item.item_search(params[:search], nil, params[:sort_by],nil,nil, params[:page], session[:user_ll], within, nil)
        elsif params[:sort_by].present? and params[:sort_by] == "friends"
          #friends items
          search_result = Item.item_search(params[:search], nil, params[:sort_by],nil,nil, params[:page], session[:user_ll], within, nil, current_user.id)
        else
          #sort by Most Recent
          search_result = Item.item_search(params[:search], nil, nil,nil,nil, params[:page], session[:user_ll], within, nil)
        end
        if search_result.present?
          @items = search_result.results
          # @distance = Item.calculate_distance(@items,session[:user_ll])
          @i_total = search_result.total
        else
          @items =[]
          @i_total = 0
        end
      #else fetch all items
      else
        @results_for = "All Goods and Services"
        if params[:sort_by].present? and (params[:sort_by] == "distance" or params[:sort_by] == "most offered")
          #sort by distance or most offered
          search_result = Item.item_search(nil, nil, params[:sort_by], nil,nil,params[:page], session[:user_ll], within, nil)
        elsif params[:sort_by].present? and params[:sort_by] == "friends"
          #friends items
          search_result = Item.item_search(nil, nil, params[:sort_by], nil,nil,params[:page], session[:user_ll], within, nil, current_user.id)
        else
          #sort by Most Recent
          search_result = Item.item_search(nil, nil, nil,nil,nil, params[:page], session[:user_ll], within, nil)
        end
        if search_result.present?
          @items = search_result.results
          # @distance = Item.calculate_distance(@items,session[:user_ll])
          @i_total = search_result.total
        else
          @items =[]
          @i_total = 0
        end
      end
      if @items.blank?
        # Empty Results Browse Page
        # Popular Items
        search_result_popular_items = Item.item_search(nil, nil, "most offered", nil,nil,1, session[:user_ll], nil,10)
        @popular_items = search_result_popular_items.results
      end
      # Friends Section        
      @friends_not_on_tradeya = current_user.friends_not_on_tradeya
      @friends_on_tradeya = current_user.friends_on_tradeya
        
      # Send email when an invited user joins
      if current_user.sign_in_count == 1 and !current_user.welcome_user and current_user.invited_by.present?
        UserMailer.friends_joined(current_user.id,current_user.invited_by).deliver
      end

    rescue StandardError => e
      @items = []
      @i_total = 0
    end
    respond_to do |format|
      if params[:page]
        format.js
      else
        format.html # index.html.erb
        format.json { render json: @items }
      end
    end
  end

  def items_distance
    dis_data = []
    uids = ""
    users = []
    if params[:ids].present? and params[:ids].length > 0
      ids = params[:ids].gsub(/\//,'')
      itms = Item.find_by_sql("SELECT id, user_id from items where id in(#{ids})")
      itms.each do |i|
        uids = uids + ((uids.length > 0) ? ",#{i.user_id}" : "#{i.user_id}")
      end
      if uids.length > 0
        users = User.find_by_sql("SELECT id, lat, lng from users where id in(#{uids})")
      end

      users_a = {}
      origin = ""

      begin
        loc = ((params[:zip].present?)? params[:zip] : session[:user_ll])
        origin = Geokit::LatLng.normalize(loc)
      rescue
        # origin = Geokit::LatLng.normalize(session[:user_ll])
      end

      if origin.present?
        users.each do |u|
          if u.lat and u.lat.present? and u.lng and u.lng.present?
            dist = ""
            begin
              dist = origin.distance_to([u.lat,u.lng])
            rescue
              dist = 9999
            end
            users_a[u.id] = dist.round(1)
          end
        end

        itms.each do |i|
          if users_a[i.user_id].present? then dis_data[dis_data.count] = [i.id, users_a[i.user_id]] end
        end
      end
    end

    render :text => dis_data.to_json
  end

  def get_user_tradeyas
    if current_user then @usr_trd = current_user.user_tradeya_ids(false) else @usr_trd = [] end
    render :text => @usr_trd.to_json
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find_by_id(params[:id])
    chk = true
    if @item and (not @item.user.active or @item.deleted?) then chk = false end
    if chk and @item
      if @item.completed?
        redirect_to accepted_offers_item_path(@item)
      elsif !@item.completed? and params[:tab].blank?
        redirect_to trade_offers_item_path(@item, :section => params[:section], :scroll => params[:scroll], :offer_by => params[:offer_by])
      end
      @like_count = @item.likes.count
      @owner = @item.user
      if @item.category.present?
        @breadcrumb = @item.category
      end
      @comments = @item.comments.where("deleted = false").includes(:user)
      begin
        if @item.category.present?
          search_result = Item.item_search(nil, @item.category_id, "most offered", nil,nil,1, session[:user_ll], nil,4)
          # debugger
          if search_result.blank? or (search_result.present? and search_result.results.count < 5)
            search_result = Item.item_search(nil, nil, "most offered",nil,nil, 1, session[:user_ll], nil,5)
          end
        else
          search_result = Item.item_search(nil, nil, "most offered",nil,nil, 1, session[:user_ll], nil,5)
        end
        similar_item = search_result.results
        @similar_items = similar_item.delete_if{|x| x.id == @item.id}
        if similar_item.count == 5
          @similar_items = similar_item.last.delete
        end
      rescue StandardError => e
        @similar_items = []
      end
      # render 'show'
    else
      redirect_to dead_link_path
    end
  end

  def new
    if params[:have].present?
      begin
        @haveItem = Item.find params[:have]
        if current_user and @haveItem.user_id == current_user.id
          @haveItem = nil
        end
      rescue
        @haveItem = nil
      end
    end
    if params[:item_saved].present?
      @item_saved = Item.find_by_id(params[:item_saved])
    elsif params[:item_edited_tradeya].present?
      @item_edited_tradeya = Item.find_by_id(params[:item_edited_tradeya])
    end
    @item = Item.new
    @item_photo = ItemPhoto.new
    @item_video = ItemVideo.new
    @item_want = ItemWant.new
    @st_pg = true
    @cat = Category.get_category(params[:cat])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/1/edit
  def edit

    @item = Item.find(params[:id])
    if !current_user
      redirect_to root_url + "?show_login=true&edit_item=#{@item.id}" and return
    end
    # check that @item.user is same as current_user else redirect
    if @item.user.id != session[:guest_user_id].to_i and (current_user.nil? or @item.user.id != current_user.id)
      redirect_to dead_link_path
      return
    end
    @item_photo = ItemPhoto.new
    @item_video = ItemVideo.new
    @item_want = ItemWant.new
    @st_pg = true
    @cat = @item.category

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item }
    end
  end

  # POST /items
  # POST /items.json
  def create
    if params[:item].present?
      # TODO - see impact
      @item = Item.new(params[:item])
      @item.user_id = current_user.id if current_user.present?

      # TODO Commented shipping information because of REQUIREMENT CHANGE (https://www.pivotaltracker.com/story/show/62299176)
      
      # @item.bring_it_to_you = params[:item][:bring_it_to_you] if params[:item][:bring_it_to_you].present?
      # @item.come_and_get_it = params[:item][:come_and_get_it] if params[:item][:come_and_get_it].present?
      # @item.lets_meet_up = params[:item][:lets_meet_up] if params[:item][:lets_meet_up].present?
      # @item.come_to_you = params[:item][:come_to_you] if params[:item][:come_to_you].present?
      # @item.come_to_me = params[:item][:come_to_me] if params[:item][:come_to_me].present?
      # @item.done_remotely = params[:item][:done_remotely] if params[:item][:done_remotely].present?
      # @item.ship_it = params[:item][:ship_it] if params[:item][:ship_it].present?
      # @item.lets_meet_service = params[:item][:lets_meet_service] if params[:item][:lets_meet_service]

      if @item.user.nil? and params[:user_id] and params[:user_id] != ''
        @item.user_id = params[:user_id]
      end
      if not @item.user_id.present? and session[:guest_user_id].to_i > 0
        @item.user_id = session[:guest_user_id].to_i
      end
      # if params[:multi_trade] and params[:multi_trade] == "on"
      #   @item.is_single_tradeya = false
      # end
      if params[:item][:tod_id].blank?
        @item.exp_date = Item.get_expiry_date_for_tod
        @item.status = "LIVE"
      else
        @item.tod = false
        @item.status = "ACTIVE"
      end
      respond_to do |format|
        if ((params[:captcha] and params[:item][:tod_id]) or params[:item][:tod_id].nil?) and not @item.user_id.blank?
          if @item.desc == "Add more details about your good or service here..." then @item.desc = "" end
          if @item.save

            # sbx tracking pixel fire
            if current_user.tracking_infos.where(affiliate:'sbx').present?
              Resque.enqueue(FireTrackingPixelJob, current_user.id, 'post')
            end

            chk = false
            # Case 1 - Old Offer - edit

            # Case 2 - New Tradeya/Offer but item selected from dropdown
            if params[:item][:selected_item_id].to_i > 0 or params[:item][:have].to_i > 0
              create_new = true
              # Create new record for item photos
            end
            # Case 3 - New Tradeya/Offer
            if params[:item_photos].present?
              photos = JSON.parse(params[:item_photos])
              if photos and photos.count > 0
                photos.each_with_index do |photo,index|
                  existing_ph = ItemPhoto.find(photo["id"])
                  if create_new and existing_ph.item_id.present?
                    ph = ItemPhoto.new
                    ph.photo = existing_ph.photo
                    ph.width = existing_ph.width; ph.height = existing_ph.height;
                    ph.crop_x = existing_ph.crop_x; ph.crop_y = existing_ph.crop_y;
                    ph.crop_w = existing_ph.crop_w; ph.crop_h = existing_ph.crop_h;
                  else
                    ph = existing_ph
                  end
                  if ph.present?
                    ph.item_id = @item.id
                    if index == 0
                      ph.main_photo = true
                    end
                    ph.save
                    chk = true
                  end
                end
              end
            end
            if params[:item_videos].present?
              videos = JSON.parse(params[:item_videos])
              if videos and videos.count > 0
                videos.each do |video|
                  existing_vi = ItemVideo.find(video["id"])
                  if create_new and existing_vi.item_id.present?
                    vi = ItemVideo.new
                    vi.video = existing_vi.vi
                  else
                    vi = existing_vi
                  end
                  if vi.present?
                    vi.item_id = @item.id
                    vi.save
                    chk = true
                  end
                end
              end
            end
            # TODO - read below and make it like below

            # if params[:file_type] == "photo"
            #   if params[:item][:item_photo] and params[:item][:item_photo][:id] and params[:item][:item_photo][:id].to_i > 0
            #     ip = ItemPhoto.find(params[:item][:item_photo][:id])
            #     ip.item_id = @item.id
            #     ip.save
            #     chk = true
            #   elsif params[:item][:item_photo]
            #     if params[:item][:item_photo][:photo]
            #       o = ItemPhoto.new(params[:item][:item_photo])
            #       o.item_id = @item.id
            #       o.save
            #       chk = true
            #     end
            #   end
            # elsif params[:file_type] == "video"
            #   if params[:item][:item_video] and params[:item][:item_video][:id] and params[:item][:item_video][:id].to_i > 0
            #     o = ItemVideo.find(params[:item][:item_video][:id])
            #     o.item_id = @item.id
            #     o.save
            #     chk = true
            #   elsif params[:item][:item_video]
            #     if params[:item][:item_video][:video]
            #       o = ItemVideo.new(params[:item][:item_video])
            #       o.item_id = @item.id
            #       o.save
            #       chk = true
            #     end
            #   end
            # end

            if not chk and params[:item][:selected_item_id].to_i > 0
              itm = Item.find(params[:item][:selected_item_id])
              if itm.item_videos and itm.item_videos.count > 0
                o = ItemVideo.new
                if File.exist?(itm.item_videos[0].video.path)
                  o.video = File.open(itm.item_videos[0].video.path)
                else
                  o.video_from_url(itm.item_videos[0].video.url)
                end
                o.item_id = @item.id
                o.save
              elsif itm.item_photos and itm.item_photos.count > 0
                o = ItemPhoto.new
                if File.exist?(itm.item_photos[0].photo.path)
                  o.photo = File.open(itm.item_photos[0].photo.path)
                else
                  o.photo_from_url(itm.item_photos[0].photo.url)
                end
                o.item_id = @item.id
                o.save
              end
            end

            # if params[:item_wants] and params[:item_wants].present?
            #   os = JSON.parse(params[:item_wants])
            #   os.each do |iwa|
            #     o = ItemWant.new
            #     o.title = iwa[0]
            #     o.category_id = iwa[1]
            #     o.desc = iwa[2]
            #     o.item = @item
            #     o.user = current_user
            #     o.save
            #   end
            # end
            if params[:item][:have].present?
              Have.create(:item_id => params[:item][:have].to_i,:user_id => current_user.id )
            end

            flash[:notice] = "item created"
            # Send mail when item created
            if (InfoAndSetting.sm_on_trd_live and @item.user.notify_tradeya_begins)
              if (@item.user.items.count == 1)
                ItemMailer.item_added_first(@item.id,@item.user.id).deliver
              elsif (@item.user.items.count < 6)
                ItemMailer.item_added(@item.id,@item.user.id).deliver
              end
              # Activity Feed
              @item.create_activity key: @item.id, owner: @item.user, recipient: @item.user
            end


            if params[:item][:tod_id] # check if the request is coming from an offer or just item
              trade = Trade.new(:item_id => params[:item][:tod_id].to_i, :offer_id => @item.id, :status => 'ACTIVE')
              trade.save!
              if params[:item][:tod] and params[:item][:tod] == "1"
                offer_as_tod = Item.new
                offer_as_tod.title = @item.title
                offer_as_tod.desc = @item.desc
                offer_as_tod.tod = true
                offer_as_tod.exp_date = Item.get_expiry_date_for_tod
                offer_as_tod.category_id = @item.category_id
                offer_as_tod.user_id = @item.user_id
                offer_as_tod.status = 'INCOMPLETE'
                offer_as_tod.is_single_tradeya = @item.is_single_tradeya
                if offer_as_tod.save
                  session[:offer_as_tod] = offer_as_tod.id
                  chk = false
                  if params[:file_type] == "photo"
                    if params[:item][:item_photo]
                      if params[:item][:item_photo] and params[:item][:item_photo][:id] and params[:item][:item_photo][:id].to_i > 0
                        ip = ItemPhoto.find(params[:item][:item_photo][:id])
                        o = ItemPhoto.new
                        if File.exist?(ip.photo.path)
                          o.photo = File.open(ip.photo.path)
                        else
                          o.photo_from_url(ip.photo.url)
                        end
                        o.item_id = offer_as_tod.id
                        o.save
                        chk = true
                      elsif params[:item][:item_photo]
                        if params[:item][:item_photo][:photo]
                          o = ItemPhoto.new(params[:item][:item_photo])
                          o.item_id = offer_as_tod.id
                          o.save
                          chk = true
                        end
                      end
                    end
                  elsif params[:file_type] == "video"
                    if params[:item][:item_video] and params[:item][:item_video][:id] and params[:item][:item_video][:id].to_i > 0
                      iv = ItemVideo.find(params[:item][:item_video][:id])
                      o = ItemVideo.new
                      if File.exist?(iv.video.path)
                        o.video = File.open(iv.video.path)
                      else
                        o.video_from_url(iv.video.url)
                      end
                      o.item_id = offer_as_tod.id
                      o.save
                      chk = true
                    elsif params[:item][:item_video]
                      if params[:item][:item_video][:video]
                        o = ItemVideo.new(params[:item][:item_video])
                        o.item_id = offer_as_tod.id
                        o.save
                        chk = true
                      end
                    end
                  end

                  if not chk and params[:archive_id].present?
                    o = ItemVideo.new
                    o.video_from_url(@url)
                    o.item_id = offer_as_tod.id
                    o.save
                    chk = true
                  end

                  if not chk and params[:item][:selected_item_id].to_i > 0
                    itm = Item.find(params[:item][:selected_item_id])
                    if itm.item_videos and itm.item_videos.count > 0
                      o = ItemVideo.new
                      if File.exist?(itm.item_videos[0].video.path)
                        o.video = File.open(itm.item_videos[0].video.path)
                      else
                        o.video_from_url(itm.item_videos[0].video.url)
                      end
                      o.item_id = offer_as_tod.id
                      o.save
                    else
                      o = ItemPhoto.new
                      if File.exist?(itm.item_photos[0].photo.path)
                        o.photo = File.open(itm.item_photos[0].photo.path)
                      else
                        o.photo_from_url(itm.item_photos[0].photo.url)
                      end
                      o.item_id = offer_as_tod.id
                      o.save
                    end
                  end
                  if session[:guest_user_id].to_i > 0
                    session[:guest_offer_as_tod] = true
                  end
                end
              else
                session[:guest_user_id] = nil
                session[:is_guest_user] = nil
              end

              # Alert.add_2_alert_q(ALERT_TYPE_TRADEYA, NEW_OFFER_ON_TRADEYA, trade.item.user.id, nil, trade.id)

              # if InfoAndSetting.sm_on_o_made then EventNotificationMailer.offer_is_made(trade).deliver end
              if InfoAndSetting.sm_on_o_made and trade.item.user.notify_received_offer then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_OFFER_MADE, trade.item.user.id, {:trade_id => trade.id}) end
              # if InfoAndSetting.sm_on_trd_live and params[:item][:tod] == '1' then EventNotificationMailer.tradeya_is_live(@item).deliver end
              # if InfoAndSetting.sm_on_trd_live and @item.user.notify_tradeya_begins?(MAIL) and params[:item][:tod] == '1' then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_IS_LIVE, @item.user.id, {:item_id => @item.id}) end
              #if InfoAndSetting.sm_on_trd_live and @item.user.notify_tradeya_begins and params[:item][:tod] == '1' then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_IS_LIVE, @item.user.id, {:item_id => @item.id}) end

              # if offer is submitted from new offer flow, id and title of offer is needed
              if params[:new_offer_flow].present? and params[:item][:is_tod].present? and (params[:item][:is_tod] == 'false') and current_user
                session[:new_offer_title] = @item.title
                session[:new_offer_id] = @item.id
              else
                session[:item_saved_offer] = true
              end
              finished("make_offer_form")
              # if current_user and !current_user.showed_onboarding
              #   format.html { redirect_to profile_url }
              # else
              format.html { redirect_to item_path(Item.find(params[:item][:tod_id])) }
              # end
            else
              session[:guest_user_id] = nil
              session[:is_guest_user] = nil
              # Alert.add_2_alert_q(ALERT_TYPE_TRADEYA, TRADEYA_LIVE, @item.user.id, @item.id)

              # if InfoAndSetting.sm_on_trd_live then EventNotificationMailer.tradeya_is_live(@item).deliver end
              # if InfoAndSetting.sm_on_trd_live and @item.user.notify_tradeya_begins?(MAIL) then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_IS_LIVE, @item.user.id, {:item_id => @item.id}) end
              #if InfoAndSetting.sm_on_trd_live and @item.user.notify_tradeya_begins then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_IS_LIVE, @item.user.id, {:item_id => @item.id}) end

              # if not session[:ipad_mini_contest].nil? and session[:ipad_mini_contest] = 5
              #   format.html{ redirect_to contest_url}
              # else

              if params[:item][:offer_for]
                if params[:item][:offer_for].include? "?"
                  format.html { redirect_to my_offers_item_path(Item.find(params[:item][:offer_for]))+ "&item_saved=" + @item.id.to_s}
                else
                  format.html { redirect_to my_offers_item_path(Item.find(params[:item][:offer_for]))+ "?item_saved=" + @item.id.to_s}
                end
              elsif params[:item][:referer_page]
                session[:have_saved] = params[:item][:referer_page]
                if params[:item][:referer_page].include? "?"
                  format.html {redirect_to params[:item][:referer_page]+ "&item_saved=" + @item.id.to_s}
                else
                  format.html {redirect_to params[:item][:referer_page]+ "?item_saved=" + @item.id.to_s}
                end
              elsif params[:item][:have_add_page]
                if params[:item][:have_add_page].include? "?"
                  format.html {redirect_to params[:item][:have_add_page]+ "&item_saved=" + @item.id.to_s}
                else
                  format.html {redirect_to params[:item][:have_add_page]+ "?item_saved=" + @item.id.to_s}
                end
              elsif params[:item][:referer_browse_page]
                if params[:item][:referer_browse_page].include? "?"
                  format.html {redirect_to params[:item][:referer_browse_page]+ "&item_saved=" + @item.id.to_s}
                else
                  format.html {redirect_to params[:item][:referer_browse_page]+ "?item_saved=" + @item.id.to_s}
                end
              else
                # session[:item_saved] = {:title => @item.title, :url => item_path(@item)}
                format.html { redirect_to new_item_path + "?item_saved=" + @item.id.to_s }
              end
              # format.html { redirect_to @item.item_url }
              # end
            end
          else
            format.html { redirect_to new_item_path }
          end
        else
          if params[:item][:tod_id]
            format.html { redirect_to item_path(Item.find(params[:item][:tod_id])) }
          else
            format.html { redirect_to new_item_path }
          end
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to new_item_path }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    if params[:id].present?
      @item = Item.find(params[:id])

      if params[:multi_trade] and params[:multi_trade] == "on"
        @item.is_single_tradeya = false
      else
        @item.is_single_tradeya = true
      end

      if !params[:item][:is_open_to_all_offers]
        @item.is_open_to_all_offers = true
      end

      #this means user has just submitted the offer as a tradeya
      if (params[:item][:tod]=="1" && @item.tod == false) or @item.incomplete?
        @item.exp_date = Item.get_expiry_date_for_tod
        @item.status = "LIVE"
        # Alert.add_2_alert_q(ALERT_TYPE_TRADEYA, TRADEYA_LIVE, @item.user.id, @item.id)
      end

      respond_to do |format|
        if not @item.user_id.blank?
          if @item.update_attributes(params[:item])
            if @item.desc == "Add more details about your good or service here..." then @item.desc = ""; @item.save end
            chk = false
            # Case 1 - Old Offer - edit

            # Case 2 - New Tradeya/Offer but item selected from dropdown
            if params[:item][:selected_item_id].to_i > 0
              create_new = true
              # Create new record for item photos
            end
            # Case 3 - New Tradeya/Offer
            if params[:item_photos].present?
              photos = JSON.parse(params[:item_photos])
              if photos and photos.count > 0
                photos.each do |photo|
                  existing_ph = ItemPhoto.find(photo["id"])
                  if create_new and existing_ph.item_id.present?
                    ph = ItemPhoto.new
                    ph.photo = existing_ph.photo
                    ph.width = existing_ph.width; ph.height = existing_ph.height;
                    ph.crop_x = existing_ph.crop_x; ph.crop_y = existing_ph.crop_y;
                    ph.crop_w = existing_ph.crop_w; ph.crop_h = existing_ph.crop_h;
                  else
                    ph = existing_ph
                  end
                  if ph.present?
                    ph.item_id = @item.id
                    ph.save
                    chk = true
                  end
                end
              end
            end
            if params[:item_videos].present?
              videos = JSON.parse(params[:item_videos])
              if videos and videos.count > 0
                videos.each do |video|
                  existing_vi = ItemVideo.find(video["id"])
                  if create_new and existing_vi.item_id.present?
                    vi = ItemVideo.new
                    vi.video = existing_vi.vi
                  else
                    vi = existing_vi
                  end
                  if vi.present?
                    vi.item_id = @item.id
                    vi.save
                    chk = true
                  end
                end
              end
            end
            # chk = false
            # if params[:file_type] == "photo"
            #   if params[:item][:item_photo]
            #     if params[:item][:item_photo][:id] and params[:item][:item_photo][:id].to_i > 0
            #       if @item.item_photos.count > 0 and not @item.item_photos[0].nil?
            #         @item.item_photos[0].destroy
            #         ip = ItemPhoto.find(params[:item][:item_photo][:id])
            #         ip.item_id = @item.id
            #         ip.save
            #         chk = true
            #       else
            #         ip = ItemPhoto.find(params[:item][:item_photo][:id])
            #         ip.item_id = @item.id
            #         ip.save
            #         chk = true
            #       end
            #     elsif params[:item][:item_photo][:photo]
            #       if @item.item_photos.count > 0
            #         @item.item_photos[0].update_attributes(params[:item][:item_photo])
            #       else
            #         o = ItemPhoto.new(params[:item][:item_photo])
            #         o.item_id = @item.id
            #         o.save
            #         chk = true
            #         @item.item_videos.each do |video|
            #           video.destroy
            #         end
            #       end
            #     end
            #   end
            # elsif params[:file_type] == "video"
            #   if params[:item][:item_video]
            #     if params[:item][:item_video][:id] and params[:item][:item_video][:id].to_i > 0
            #       if @item.item_videos.count > 0 and not @item.item_videos[0].nil?
            #         @item.item_videos[0].destroy
            #         o = ItemVideo.find(params[:item][:item_video][:id])
            #         o.item_id = @item.id
            #         o.save
            #         chk = true
            #       else
            #         o = ItemVideo.find(params[:item][:item_video][:id])
            #         o.item_id = @item.id
            #         o.save
            #         chk = true
            #       end
            #     elsif params[:item][:item_video][:video]
            #       if @item.item_videos.count > 0
            #         @item.item_videos[0].update_attributes(params[:item][:item_video])
            #       else
            #         o = ItemVideo.new(params[:item][:item_video])
            #         o.item_id = @item.id
            #         o.save
            #         chk = true
            #         @item.item_photos.each do |photo|
            #           photo.destroy
            #         end
            #       end
            #     end
            #   end
            # end

            if not chk and params[:archive_id].present?
              opentok = OpenTok::OpenTokSDK.new OPENTOK_API_KEY, OPENTOK_API_SECRET
              otArchive = opentok.get_archive_manifest(params[:archive_id], InfoAndSetting.tb_token)
              otVideoResource = otArchive.resources[0]
              videoId = otVideoResource.getId()
              url = otArchive.downloadArchiveURL(videoId, InfoAndSetting.tb_token)

              if @item.item_videos and @item.item_videos.count > 0
                @item.item_videos[0].video_from_url(url)
                @item.item_videos[0].save
              else
                o = ItemVideo.new
                o.video_from_url(url)
                o.item_id = @item.id
                o.save
              end
              @item.item_photos.each do |photo|
                photo.destroy
              end
            end

            # if params[:item_wants] and params[:item_wants].present?
            #   @item.item_wants.each do |want|
            #     want.destroy
            #   end
            #   os = JSON.parse(params[:item_wants])
            #   os.each do |iwa|
            #     o = ItemWant.new
            #     o.title = iwa[0]
            #     o.category_id = iwa[1]
            #     o.desc = iwa[2]
            #     o.item = @item
            #     o.user = current_user
            #     o.save
            #   end
            # end

            flash[:notice] = "item updated"
            if params[:item][:edit_offer] # check if the request is coming from an offer or just item
              trades = Trade.find(:all, :conditions => {:offer_id => @item.id})
              trades.each do |trd|
                if trd.item.live? and !trd.offer_deleted?
                  # Alert.add_2_alert_q(ALERT_TYPE_TRADEYA, OFFER_EDITED, trd.item.user.id, nil, trd.id)

                  # mail notification (Mohammad faizan)
                  # if trd.item.user.notify_offer_changed?(MAIL) then EventNotificationMailer.offer_on_tradeya_edited(trd.item,trd.offer).deliver end
                  if trd.item.user.notify_offer_changed then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_OFFER_ON_TRADEYA_EDITED, trd.item.user.id, {:trade_id => trd.id}) end
                end
              end
              session[:item_edited_offer] = true
              format.html { redirect_to item_path(Item.find(params[:item][:tod_id])) }
            else
              if @item.expired? or @item.postponed? or @item.completed?

                # mail notification for publisher
                if (@item.expired? and @item.user.notify_tradeya_expired_reactivated) or ((@item.postponed? or @item.completed?) and @item.user.notify_tradeya_postponed_reactivated)
                  # EventNotificationMailer.tradeya_reactivated(@item).deliver
                  # EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_REACTIVATED, @item.user.id, {:item_id => @item.id})
                  EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_REACTIVATED, @item.user.id, {:item_id => @item.id})
                end
                exp = @item.expired?
                post = @item.postponed?
                @item.exp_date = Item.get_expiry_date_for_tod
                @item.status = 'LIVE'
                @item.is_mail_sent_24 = false
                @item.is_mail_sent_12 = false
                @item.save
                @item.trades.each do |trd|
                  if !trd.offer_deleted?
                    # Alert.add_2_alert_q(ALERT_TYPE_OFFER, TRADEYA_RESUBMITTED, trd.offer.user.id, trd.item.id, trd.id)
                    if (exp and trd.offer.user.notify_tradeya_expired_reactivated) or (post and trd.offer.user.notify_tradeya_postponed_reactivated) or trd.offer.user.notify_offer_turned_invalid
                      EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_RESUMED, trd.offer.user.id, {:trade_id => trd.id}) end
                  end

                  # offerer's notification mail
                  # EventNotificationMailer.tradeya_resumed(@item,trd.offer).deliver

                end
              end

              # session[:item_edited_tradeya] = true
              # format.html { redirect_to @item.item_url }
              if params[:item][:referer_edit_page]
                format.html {redirect_to params[:item][:referer_edit_page]}
              elsif params[:item][:haves_tab]
                format.html {redirect_to params[:item][:haves_tab]}
              else
                #session[:item_edited_tradeya] = {:title => @item.title, :url => item_path(@item)}
                # format.html { redirect_to new_item_path }
                format.html { redirect_to new_item_path + "?item_edited_tradeya=" + @item.id.to_s }
              end
            end
            session[:guest_user_id] = nil
            session[:is_guest_user] = nil
          else
            if params[:item][:edit_offer] # check if the request is coming from an offer or just item
              format.html { redirect_to item_path(Item.find(params[:item][:tod_id])) }
            else
              format.html { redirect_to edit_item_path(@item.id) }
            end
          end
        else
          if params[:item][:edit_offer] # check if the request is coming from an offer or just item
            format.html { redirect_to item_path(Item.find(params[:item][:tod_id])) }
          else
            format.html { redirect_to edit_item_path(@item.id) }
          end
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to new_item_path }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json

  #TODO:in phase 2, send notifications to users who had put reviews, comments or offers on the deleted item
  def destroy
    if params[:id].present?
      begin
        @item = Item.find(params[:id])
        @item.update_attribute("status","DELETED")
        session[:delete_item] = params[:id]
        # @item.comments.each do |cm|
        #   cm.destroy
        # end
        # render :text => "success"
        redirect_to haves_user_path(current_user)
      rescue
        render :text => "error"
      end
    end
  end

  # def namelink
  #   session[:guest_offer_as_tod] = nil
  #   # if not params[:offer_form].present? then params[:offer_form] = ab_test("make_offer_form", "form", "new_make_offer") end

  #   @item = Item.find_by_id(params[:id])
  #   chk = true
  #   if @item and (not @item.user.active or @item.deleted?) then chk = false end

  #   if chk and @item
  #     # @tradeyas = Item.current_tradeyas
  #     # @item = current_user.tradeya
  #     @user_wants =  @item.user.goods + ',' +  @item.user.services
  #     @userReviews = User.get_user_reviews(@item.user_id)
  #     @comments = Comment.item_comments(@item.id)
  #     @accepted_offers = @item.accepted_trades
  #     @trades = @item.other_trades
  #     @status = @item.item_status
  #     # Generating Reviews about offerers
  #     @offererReviews = Array.new
  #     @trades.each do |trade|
  #       offerer = trade.offer.user_id
  #       @offererReviews.push(User.get_user_reviews(offerer))
  #     end
  #     # Generating Reviews about accepted offerers
  #     @accepted_offererReviews = Array.new
  #     @accepted_offers.each do |trade|
  #       offerer = trade.offer.user_id
  #       @accepted_offererReviews.push(User.get_user_reviews(offerer))
  #     end
  #     @offer_open4cats = @item.offer_open4cats
  #     @item_photo = ItemPhoto.new
  #     @item_video = ItemVideo.new
  #     @offer = Item.new
  #     # @item_want = ItemWant.new

  #     @pub = false
  #     @offerer = false
  #     @past_offer_tradeyas = []
  #     if current_user
  #       @pub = current_user.pub?(@item)
  #       @offerer = current_user.offerer?(@item.id)
  #     end

  #     #Generating mutual connections
  #     @mc = Hash.new  #mutual connections
  #     @amc = Hash.new  #accepted mutual connections
  #     @offerer_mc = [] #offerer or potential offerer's mutual connection with item owner

  #     if @pub
  #       @trades.each do |trade|
  #         if !@mc[trade.offer.user.id] or @mc[trade.offer.user.id].nil?
  #           @mc[trade.offer.user.id] = MutualFriend.get_mutual_friends_details(current_user.id, trade.offer.user.id)
  #           # connections = User.get_mutual_frnds(current_user,trade.offer.user)
  #           # connections = fb_mutual_friends(current_user,trade.offer.user)
  #           # connections.concat(twitter_mutual_friends(current_user,trade.offer.user))
  #           # @mc[trade.offer.user.id] = connections
  #         end
  #       end
  #       @accepted_offers.each do |trade|
  #         if !@amc[trade.offer.user.id] or @amc[trade.offer.user.id].nil?
  #           @amc[trade.offer.user.id] = MutualFriend.get_mutual_friends_details(current_user.id, trade.offer.user.id)
  #           # connections = User.get_mutual_frnds(current_user,trade.offer.user)
  #           # connections = fb_mutual_friends(current_user,trade.offer.user)
  #           # connections.concat(twitter_mutual_friends(current_user,trade.offer.user))
  #           # @amc[trade.offer.user.id] = connections
  #         end
  #       end
  #     elsif current_user
  #       #offerer or potential offerer's mutual connection with item owner
  #       # connections = User.get_mutual_frnds(current_user,@item.user)
  #       # connections = fb_mutual_friends(current_user,@item.user)
  #       # connections.concat(twitter_mutual_friends(current_user,@item.user))
  #       # @offerer_mc = connections
  #       @offerer_mc = MutualFriend.get_mutual_friends_details(current_user.id, @item.user.id)
  #     end

  #     session[:item_id] = @item.id

  #     render 'show'
  #   else
  #     render "common/dead_link"
  #   end
  # end

  def search_by_zip
    begin
      if params[:zipcode] and params[:zipcode].present? and Item.isNumber(params[:zipcode])
        search_result = Item.search_by_zipcode(params[:zipcode],session[:user_ll])
        @items = search_result[0]
        # @completed = search_result[1]
        @distance = search_result[2]
        # @comp_distance = search_result[3]
        @completed = []
        @comp_distance = []
        @usr_trd = []
        if current_user then @usr_trd = current_user.user_tradeya_ids(false) end
      else
        @completed = []
        @items = []
      end
    rescue
      @completed = []
      @items = []
    end
  end

  def complete_trade
    begin
      item = Item.find(params[:item_id])
      item.complete_trade
      render :text => "true"
    rescue
      render :text => "false"
    end
  end

  def postpone_trade
    begin
      if Item.postpone_trade(params[:item_id])
        item = Item.find(params[:item_id])
        item.trades.each do |trd|
          if !trd.offer_deleted?
            # Alert.add_2_alert_q(ALERT_TYPE_OFFER, TRADEYA_POSTPHONED, trd.offer.user.id, item.id, trd.id)
          end
        end

        #mail notification to publisher
        # if item.user.notify_tradeya_over?(MAIL) then EventNotificationMailer.tradeya_postponed_pub(item).deliver end
        # if item.user.notify_tradeya_over?(MAIL) then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_POSTPONED_PUB, item.user.id, {:item_id => item.id}) end
        if item.user.notify_tradeya_postponed_reactivated then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_POSTPONED_PUB, item.user.id, {:item_id => item.id}) end

        render :text => "success"
      else
        render :text => "failure"
      end
    rescue StandardError => e
      render :text => "error"
    end
  end

  def crop_image
    data = {}
    if params[:is_item_photo] == "true"
      ip = ItemPhoto.find(params[:id])
      ip.update_attributes(params[:ip])
      data[:url] = ip.photo.url(:large)
    else
      up = UserPhoto.find(params[:id])
      up.update_attributes(params[:ip])
      data[:url] = up.photo.url(:large)
    end
    render :text => data.to_json
  end

  def clear_cache
    if params[:id].present?
      Item.find(params[:id]).save
    else
      Item.first.save
    end

    render :text => 'cleared'
  end

  def browse_all
    page = 1
    begin
      if params[:search]
        search_result = Item.item_search(params[:search])
        if search_result.length > 0
          @items = Item.get_live_tradeyas(nil,nil,page,search_result)
          @i_total = @items.total_entries
          @completed,@c_total = Item.get_completed_tradeyas(nil,nil,nil,page,search_result)
        else
          @items =[]
          @completed = []
          @i_total = 0
          @c_total = 0
        end
      else
        @items = Item.get_live_tradeyas(nil,nil,page)
        @i_total = @items.total_entries
        @completed,@c_total = Item.get_completed_tradeyas(nil,nil,nil,page)
      end
      cmp_items = []
      @completed.each do |x|
        cmp_items.push(x[0])
      end
      @distance = Item.calculate_distance(@items,session[:user_ll])
      @comp_distance = Item.calculate_distance(cmp_items,session[:user_ll])
    rescue StandardError => e
      @items = []
      @completed = []
      @i_total = 0
      @c_total = 0
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @items }
    end
  end

  def profile_page
  end

  #--------------------------------------------------------------------------#
  # like ----> "Like/Unlike an item"
  # Params --- IN:
  # +params[:id]+::"item_id"
  # +params[:like]+:: " Boolean indicating like or unlike"
  # Params --- OUT:
  # +@item+:: item object based on params[:id]
  # +@like_count+:: returns like counts
  #--------------------------------------------------------------------------#
  def like
    @item = Item.find_by_id(params[:id])
    like_data = Like.find_by_item_id_and_user_id(params[:id],current_user.id)
    if params[:like] == "true" or params[:item_card_like] == "true"
      if like_data.blank?
        Like.create(:item_id => params[:id],:user_id => current_user.id )
      end
      like = Like.find_by_item_id_and_user_id(params[:id],current_user.id)
      # Send mail if item liked
      ItemMailer.item_liked(@item.id,current_user.id).deliver
      # Activity Feed
      like.create_activity key: @item.id, owner: current_user, recipient: @item.user

    elsif params[:remove_item] == "true" or like_data
      like_data.destroy
    end
    if params[:remove_item]
      @user = current_user
      @liked_items = @user.liked_items
      if @liked_items.blank?
        search_result = Item.item_search(nil, nil, "most offered",nil,nil, 1, session[:user_ll], nil,10)
        @items = search_result.results
        @distance = Item.calculate_distance(@items,session[:user_ll])
      end
    end
    @like_count = Like.where(:item_id => params[:id]).count
    respond_to do |format|
      format.js
      format.html {
        if params[:remove_item]
          redirect_to likes_user_path(@user)
        elsif params[:like]
          redirect_to item_path(@item)
        end
      }
    end
  end

  #--------------------------------------------------------------------------#
  # haves ----> "User can add the item to his haves list"
  # Params --- IN:
  # +params[:id]+::"item_id"
  # +params[:haves]+:: " Boolean indicating haves or not"
  # Params --- OUT:
  # +@item+:: item object based on params[:id]
  # +@haves_count+:: returns user's haves count of the item
  #--------------------------------------------------------------------------#
  def haves
    @item = Item.find_by_id(params[:id])
    haves_data = Have.find_by_item_id_and_user_id(params[:id],current_user.id)
    if params[:haves] == "true"
      if haves_data.blank?
        Have.create(:item_id => params[:id],:user_id => current_user.id )
      end
    elsif haves_data
      haves_data.destroy
    end
    @haves_count = @item.user.haves.count if @item.user.present?
    respond_to do |format|
      format.js
      format.html { redirect_to item_path(@item)}
    end
  end

  #--------------------------------------------------------------------------#
  # wants ----> "User can add and remove an item to his wants list"
  # Params --- IN:
  # +params[:id]+::"item_id"
  # +params[:wants]+:: " Boolean indicating wants or not"
  # Params --- OUT:
  # +@item+:: item object based on params[:id]
  # +@wants_count+:: returns user's wants count of the item
  #--------------------------------------------------------------------------#
  def wants
    @item = Item.find_by_id(params[:id])
    @user = current_user
    wants_data = Want.find_by_item_id_and_user_id(params[:id],@user.id)
    if params[:item_page_want] == "true" or params[:item_card_want] == "true"
      if wants_data.blank?
        Want.create(:item_id => params[:id],:user_id => current_user.id )

        # Send mail if item wanted
        if @user.wants.count == 1 # 1st want
          if @user.items.count < 10
            ItemMailer.item_wanted_first_less_haves(@item.id,@user.id).deliver
          else
            ItemMailer.item_wanted_first_more_haves(@item.id,@user.id).deliver
          end
        else
          if @user.items.count < 10
            ItemMailer.item_wanted_less_haves(@item.id,@user.id).deliver
          else
            ItemMailer.item_wanted_more_haves(@item.id,@user.id).deliver
          end
        end
        if @item.user.owned_wanted_items.count == 1
          # Item Owner's first want
          ItemMailer.item_wanted_first_owner(@item.id,@user.id).deliver
        else
          ItemMailer.item_wanted_owner(@item.id,@user.id).deliver
        end

        want = Want.find_by_item_id_and_user_id(@item.id,@user.id)
        # Activity Feed
        want.create_activity key: @item.id, owner: @user, recipient: @item.user

      end
    elsif params[:remove_want] or wants_data
      wants_data.destroy
    end
    if params[:remove_want]
      @user = current_user
      @wanted_items = @user.wanted_items
      if @wanted_items.blank?
        search_result = Item.item_search(nil, nil, "most offered", nil,nil,1, session[:user_ll], nil,10)
        @items = search_result.results
        # @distance = Item.calculate_distance(@items,session[:user_ll])
      end
    end
    @wants_count = @item.user.wants.count if @item.user.present?
    respond_to do |format|
      format.js
      format.html {
        if params[:remove_want]
          redirect_to user_path(:id => @user, :tab => "wants")
        else
          redirect_to item_path(@item)
        end
      }
    end
  end

  def trade_offers
    if params[:id].present?
      @item = Item.find_by_id(params[:id])
      @trade_offers_tab = @item.trades.activeOffers.with_live_offer.all(:order => "updated_at desc")
      @like_count = @item.likes.count
      @owner = @item.user
      if @item.category.present?
        @breadcrumb = @item.category
      end
      @comments = @item.comments.where("deleted = false").includes(:user)
      if params[:offer_by].present?
        flash[:error] = "Rollover on the item card to accept/reject the offer or leave a comment for " + params[:offer_by]
      elsif params[:scroll] == "true"
        flash[:error] = "Rollover on the item card to accept/reject the offer or leave a comment for " + @trade_offers_tab.last.offer.user.first_name.titleize
      elsif params[:reject_of].present?
        flash[:notice]= "You've rejected "+ params[:reject_of] +"'s offer. It has been moved to \"Rejected Offers\" ."
      end
      begin
        if @item.category.present?
          search_result = Item.item_search(nil, @item.category_id, "most offered", nil,nil,1, session[:user_ll], nil,4)
          if search_result.blank? or (search_result.present? and search_result.results.count < 5)
            search_result = Item.item_search(nil, nil, "most offered",nil,nil, 1, session[:user_ll], nil,5)
          end
        else
          search_result = Item.item_search(nil, nil, "most offered",nil,nil, 1, session[:user_ll], nil,5)
        end
        similar_item = search_result.results
        @similar_items = similar_item.delete_if{|x| x.id == @item.id}
        if similar_item.count == 5
          @similar_items = similar_item.last.delete
        end
      rescue StandardError => e
        @similar_items = []
      end
    end
  end

  def my_offers
    #parameters defined here need to be passed in remove_have method also accordingly
    @item = Item.find_by_id(params[:id])
    if current_user.present?
      @offeredItemsAsTrades = @item.active_offers_by_user(current_user.id)
      @have_items = current_user.have_items
      @wanted_items =  Want.joins(:user,:item).where('users.id'=>@item.user_id,'items.user_id'=>current_user.id,'items.status'=>'LIVE')
      @item_array = @wanted_items.collect{|w| w.item_id}
      @wantedItemInTrades = @offeredItemsAsTrades.collect{|of| of.offer_id}

    else
      @have_items = []
    end
    @trade = Trade.new
    @like_count = @item.likes.count
    @owner = @item.user
    if @item.category.present?
      @breadcrumb = @item.category
    end
    @comments = @item.comments.where("deleted = false").includes(:user)
    begin
      if @item.category.present?
        search_result = Item.item_search(nil, @item.category_id, "most offered",nil,nil, 1, session[:user_ll], nil,4)
        # debugger
        if search_result.blank? or (search_result.present? and search_result.results.count < 5)
          search_result = Item.item_search(nil, nil, "most offered",nil,nil, 1, session[:user_ll], nil,5)
        end
      else
        search_result = Item.item_search(nil, nil, "most offered",nil,nil, 1, session[:user_ll], nil,5)
      end
      similar_item = search_result.results
      @similar_items = similar_item.delete_if{|x| x.id == @item.id}
      if similar_item.count == 5
        @similar_items = similar_item.last.delete
      end
    rescue StandardError => e
      @similar_items = []
    end

    flash.clear
    if session[:offered_item]
      flash[:notice] = "Congratulations you've offered your \""+session[:offered_item]+ "\" for " + @item.user.first_name.titleize + "'s \"" + @item.title + "\". We'll let you know when " + @item.user.first_name.titleize + " responds. Drag and drop more items to give " + @item.user.first_name.titleize + " more options to choose from."
      # session.delete :offered_item
    elsif params[:wanted_item].present?
      @item_want = Item.find(params[:wanted_item])
      if @item_want.completed? or @item_want.deleted?
        flash[:info] = "Drag something from your Haves Board and drop it onto the \"+Offer\" card to make an offer on \""+@item.title+"\"."
      elsif !@item_want.completed? or !@item_want.deleted?
        flash[:info] = "Please confirm your offer on " + @item.user.first_name.titleize.titleize + "'s item. If you'd like to make additional offers, drag items from \"Your Haves\" section and drop them to \"+Offer\"."
      end
    elsif params[:wanted_item].blank?
      flash[:error] = "Drag something from your Haves Board and drop it onto the \"+Offer\" card to make an offer on \""+@item.title+"\"."
    end
    respond_to do |format|
      format.html
      format.js {render :action => "my_offers"}
    end
  end

  def accepted_offers
    if params[:id].present?
      @item = Item.find_by_id(params[:id])
      @accepted_trades = @item.total_accepted_trades
      # @accepted_offers = @item.accepted_offers
      @like_count = @item.likes.count
      @owner = @item.user
      if @item.category.present?
        @breadcrumb = @item.category
      end
      @comments = @item.comments.where("deleted = false").includes(:user)
      begin
        if @item.category.present?
          search_result = Item.item_search(nil, @item.category_id, "most offered", nil,nil,1, session[:user_ll], nil,4)
          # debugger
          if search_result.blank? or (search_result.present? and search_result.results.count < 5)
            search_result = Item.item_search(nil, nil, "most offered", nil,nil,1, session[:user_ll], nil,5)
          end
        else
          search_result = Item.item_search(nil, nil, "most offered", nil,nil,1, session[:user_ll], nil,5)
        end
        similar_item = search_result.results
        @similar_items = similar_item.delete_if{|x| x.id == @item.id}
        if similar_item.count == 5
          @similar_items = similar_item.last.delete
        end
      rescue StandardError => e
        @similar_items = []
      end
    end
  end

  def rejected_offers
    if params.present?
      @item = Item.find_by_id(params[:id])
      @rejected_offers = @item.rejected_offers
      @like_count = @item.likes.count
      @owner = @item.user
      @trade = Trade.new
      if @item.category.present?
        @breadcrumb = @item.category
      end
      @comments = @item.comments.where("deleted = false").includes(:user)
      begin
        if @item.category.present?
          search_result = Item.item_search(nil, @item.category_id, "most offered", nil,nil,1, session[:user_ll], nil,4)
          # debugger
          if search_result.blank? or (search_result.present? and search_result.results.count < 5)
            search_result = Item.item_search(nil, nil, "most offered", nil,nil,1, session[:user_ll], nil,5)
          end
        else
          search_result = Item.item_search(nil, nil, "most offered", nil,nil,1, session[:user_ll], nil,5)
        end
        similar_item = search_result.results
        @similar_items = similar_item.delete_if{|x| x.id == @item.id}
        if similar_item.count == 5
          @similar_items = similar_item.last.delete
        end
      rescue StandardError => e
        @similar_items = []
      end
    end
  end

  # TODO review the flow
  def remove_have
    if params[:id].present? and params[:remove_have].present?
      if params[:from_haves_tab] == 'true'
        @user = current_user
        # @have_items = @user.items
        item = Item.find_by_id_and_user_id(params[:id],current_user.id)
        if item.present?
          # item.destroy
          item.update_attribute("status","DELETED")
        end
        flash[:info] = "Item has been removed from your Haves Board ."
        redirect_to haves_user_path(@user, :delete => item.id)
        # elsif params[:from_my_offers_tab] == 'true'
        #   @user = current_user
        #   @have_items = @user.have_items
        #   item = Item.find_by_id_and_user_id(params[:id],current_user.id)
        #   item.destroy
        #   params[:id] = params[:original_id]
        #   @item = Item.find_by_id(params[:id])
        #   @offer_ids = @item.current_offers.pluck(:offer_id)
        #   @useritems = @user.items
        #   @useritem_ids = @useritems.pluck(:id)
        # elsif params[:from_items_index] == 'true'
        #   # item = Item.find_by_id(params[:id])
        #   # item.destroy
        #   respond_to do |format|
        #   format.js
        #   format.html { redirect_to items_path}
        # end
      end
    end
  end

  def remove_offer
    if params.present?
      trade = Trade.find_by_offer_id(params[:id])
      if trade.present?
        params.delete :offered_item
        trade.destroy
      end
    end
    redirect_to my_offers_item_path(trade.item)
  end

  def want_cancel
    want = Want.find_by_item_id_and_user_id(params[:want_id],params[:user_id])
    if want.cancelled_wants.blank?
      want.cancelled_wants = params[:item_id].to_s
    else
      want.cancelled_wants += "," + params[:item_id].to_s
    end
    want.save
    redirect_to :back
  end

  def main_photo
    if params[:id].present?
      @item = Item.find(params[:id])
      main_image = ItemPhoto.find(params[:photo_id])
      @item.item_photos.update_all(:main_photo => false)
      main_image.update_attributes(:main_photo => true)
    end
    respond_to do |format|
      format.js
    end
  end

  def request_info
    if params[:id].present?
      @item = Item.find(params[:id])
      request_info = RequestInfoItem.new
      request_info.item_id = @item.id
      request_info.user_id = current_user.id
      request_info.more_photos = params[:more_photos]
      request_info.additional_description = params[:additional_description]
      request_info.verify_condition = params[:verify_condition]
      request_info.ask_question = params[:ask_question]
      request_info.save
      ItemMailer.request_for_more_info(request_info.id).deliver
    end
  end

  def edit_photo
    if params[:id].present?
      @photo = ItemPhoto.find_by_id(params[:id])
      contents = Magick::Image.read(params[:url]).first
      file = Tempfile.new(["Edited_Photo", ".jpg"])
      contents.write(file.path)
      @photo.update_attributes(:photo=>file)
    end
    respond_to do |format|
      format.js
    end
  end

  def trade_page
    
  end

  def wants_detail
    if params[:id].present?
      @item = Item.find(params[:id])
      @item_trades = @item.trades
      @item_likes = @item.likes
      @item_wants = @item.wants
    end

    respond_to do |format|
      format.js
    end
  end
end
