class Item < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include PublicActivity::Common

  self.per_page = 10

  validates :title, :presence => true
  # validates :category_id, :presence => true
  validates :user_id, :presence => true

  # ACTIVE_TRADEYAS = " tod = true AND exp_date > 'TODAY' AND (status IS NULL OR status = 'LIVE') "
  ACTIVE_TRADEYAS = " tod = true AND (quantity > 0 or qty_unlimited = true) AND (status IS NULL OR status = 'LIVE') "

  belongs_to :user
  has_many :trades, :dependent => :restrict
  has_many :reverse_trades, :class_name => "Trade", :foreign_key => "offer_id", :dependent => :destroy
  has_many :item_photos, :dependent => :destroy
  has_many :item_videos, :dependent => :destroy
  has_many :item_wants, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :alerts, :dependent => :destroy
  has_many :featured_tradeyas, :dependent => :destroy
  belongs_to :category
  has_many :likes, :dependent => :destroy
  has_many :haves,:class_name => "Have", :dependent => :destroy
  has_many :wants,:class_name => "Want", :dependent => :destroy
  has_many :passive_trades


  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :item_photos, :allow_destroy => true

  scope :all_tradeyas, :conditions => [ "tod = 1" ]
  scope :live, :conditions => "status = 'LIVE' and (quantity > 0 or qty_unlimited)"
  # TODO - change it for active admin
  scope :upcoming_tradeyas, lambda {
    # today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    cur_trd_ids = InfoAndSetting.current_tradeyas.to_s
    cur_trd_ids = cur_trd_ids[1, cur_trd_ids.length - 2]
    if cur_trd_ids.length > 0
      where("#{ACTIVE_TRADEYAS} AND id NOT IN(#{cur_trd_ids})")
    else
      where(ACTIVE_TRADEYAS)
    end
  }

  scope(:traded_tradeyas,
        :conditions => [ "id IN(SELECT DISTINCT item_id FROM trades WHERE id IN(SELECT trade_id FROM accepted_offers WHERE recent_tradeya = 1)) AND tod = 1" ])

  scope(:offered_not_traded_tradeyas,
        :conditions => [ "id IN(SELECT DISTINCT item_id FROM trades WHERE id NOT IN(SELECT trade_id FROM accepted_offers WHERE recent_tradeya = 1)) AND tod = 1"])

  scope(:offers,
        :conditions => [ "id IN(SELECT DISTINCT offer_id FROM trades)" ],
        :order => 'created_at desc')

  scope(:not_traded_offers,
        :conditions => [ "id IN(SELECT DISTINCT offer_id FROM trades WHERE id NOT IN(SELECT DISTINCT trade_id FROM accepted_offers))" ])

  scope(:traded_offers,
        :conditions => [ "id IN(SELECT DISTINCT offer_id FROM trades WHERE id IN(SELECT DISTINCT trade_id FROM accepted_offers))" ])

  attr_accessible :title, :desc, :user_attributes, :user, :tod, :exp_date,
  :category_id, :is_open_to_all_offers, :open4categories, :quantity,
  :qty_unlimited, :delivery_desc, :delivery, :condition, :bring_it_to_you, :come_and_get_it, :lets_meet_up,
  :come_to_you, :come_to_me, :done_remotely, :ship_it, :lets_meet_service



  # after_save :update_user_tradeya_count
  # after_destroy :update_user_tradeya_count

  # search
  # ------------
  searchable do
    integer :id
    text :title
    text :desc
    text :item_location
    text :item_zip
    latlon (:location) {
      Sunspot::Util::Coordinates.new(user.lat, user.lng) if user.lat.present? and user.lng.present?
    }
    string :status
    integer :category_id
    time :created_at
    integer :delivery
    integer :item_offers_count
    integer :condition

  end

  def to_param
    if(self.user.present?) 
      if self.category.present?
        "#{id} #{category.parent.name} #{category.name} #{title} #{self.user.location} #{self.user.display_name}".parameterize
      else
        "#{id} #{title} #{self.user.location} #{self.user.display_name}".parameterize
      end
    else
      "dead_link" 
    end

    # [id,self.user.display_name.parameterize].join("/")
    # id.to_s + '/' + category.parent.name.gsub(/\s+/, "-").gsub(/\.+/, "-") + '/' + category.name.gsub(/, /, ",").gsub(/\s+/, "-").gsub(/\.+/, "").gsub("/","") + '/' + title.gsub(/\s+/, "-").gsub(/\.+/, "-") + '/' + self.user.location.gsub(/\s+/, "-").gsub(/\.+/, "-") + '/' + self.user.title.gsub(/\s+/, "-").gsub(/\.+/, "-")
  end

  def item_location
    return self.user.location
  end

  def item_offers_count
    return self.trades.count
  end

  def item_zip
    zip = self.user.zip
    if zip.present?
      return zip
    else
      return ""
    end
  end

  def update_user_tradeya_count
    if self.tod
      user = self.user
      if user.present?
        user.update_attribute("tradeya_count",user.get_user_live_tradeya_count)
      end
    end
  end

  def self.item_search(search = nil, cat = nil, sort = nil, condition = nil, delivery = nil, page = nil, usrll = nil, within = nil, perpage = nil, current_user_id = nil)
    origin = []
    if usrll.present?
      begin
        origin = Geokit::LatLng.normalize(usrll).to_a()
      rescue
        origin = Geokit::LatLng.normalize(usrll).to_a()
      end
    else
      origin = [34.0126379,-118.495155]
    end
    if sort.present? and sort == "friends" and current_user_id.present?
      friends_item_ids = User.find_by_id(current_user_id).friends_items
    end
    begin
      search = Item.solr_search(:include => [:user]) do
        if search.present?
          fulltext search
        end
        if cat.present?
          with(:category_id, cat)
        end
        if condition.present?
          with(:condition, condition)
        end
        if delivery.present?
          with(:delivery, delivery)
        end
        if sort.present?
          if sort == "distance"
            order_by_geodist(:location,origin[0],origin[1])
          elsif sort == "most offered"
            order_by(:item_offers_count, :desc)
          elsif sort == "friends"
            with(:id,friends_item_ids)
          else
            order_by(:created_at, :desc)
          end
        else
          order_by(:created_at, :desc)
        end
        if within.present?
          with(:location).in_radius(origin[0], origin[1], within) unless origin.nil?
        end
        with(:status, "LIVE")
        if perpage.present?
          paginate :per_page => perpage, :page => page
        else
          paginate :per_page => 20, :page => page
        end
      end
      if sort == "friends" and !friends_item_ids.present?
        search = nil
      end
    rescue StandardError => e
      search = nil
    end
    return search
  end

  class << self; attr_accessor :default_title end
  @default_title = 'Write a title for your good or service here...'

  def init
    # self.title ||= Item.default_title
  end

  def self.get_expiry_date_for_tod
    return (Time.zone.now + 45.days).to_datetime.strftime("%Y-%m-%d %H:%M:%S")
  end

  def self.test_facebook_cache
    return HTTParty.get 'http://developers.facebook.com/tools/debug/og/object?q=http%3A%2F%2Ftradeya.addvalsolutions.com', :headers => {"User-Agent" => 'Mozilla/5.0'}
  end

  def item_type
    if tod then return 'SPOTLIGHT' else 'OFFER' end
  end

  def item_title
    return self.title.capitalize
  end

  # TODO - redo it

  # this method use in dashboard Active Admin interface for get upcoming tradeya
  def self.tradeyas
    # today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    tods = Item.find(
                     :all,
                     :conditions => "tod=true AND (quantity > 0 or qty_unlimited = true)",
                     :order => "created_at DESC", :limit => 25)
    trds = []
    tods.each do |t|
      if not t.exp_date.nil?
        trds[trds.count] = t
      end
    end
    tods.each do |t|
      if t.exp_date.nil?
        trds[trds.count] = t
      end
    end
    return trds
  end

  def self.tradeyas_canbe_featured(limit = 25)
    query = self.get_query_for_active_tradeyas
    query = query + " AND ID NOT IN (select item_id from featured_tradeyas where #{FeaturedTradeya.current_featured_list_condition})"
    if limit.nil?
      tods = Item.find(:all, :conditions => query, :order => "created_at DESC")
    else
      tods = Item.find(:all, :conditions => query, :order => "created_at DESC", :limit => limit)
    end
    return tods
  end

  # TODO - see if this can be created_at desc
  def self.current_tradeyas(limit = 5, is_dup_allow = true)
    query = self.get_query_for_active_tradeyas
    tods = Item.find(:all, :conditions => query, :order => "created_at DESC", :limit => limit)

    if tods.length == 0
      tods = [Item.find_by_title('Beats by Dr. Dre')]
    end

    if is_dup_allow
      trds = []
      if tods.count < 5 and limit == 5
        c = 0
        r = tods.count

        ((tods.count)..(5 - 1)).each do |i|
          tods[i] = tods[c]
          if c < r then c = c + 1 else c = 0 end
        end
      end
    end
    return tods
  end

  def self.set_current_category_tradeyas(chk_users = false,limit=5, is_dup_allow = true)
    current_category = InfoAndSetting.current_category
    query = self.get_query_for_active_tradeyas
    tods_by_cat = []
    if chk_users
      tods_by_cat = Item.find(:all,
                              :conditions =>  query + " AND category_id = " + current_category.to_s,
                              :group => "user_id",
                              :order => "created_at DESC",
                              :limit => limit)
    else
      tods_by_cat = Item.find(:all,
                              :conditions => query + " AND category_id = " + current_category.to_s,
                              :order => "current_spotlight DESC")
    end
    return tods_by_cat
  end

  def self.current_category_tradeyas(limit=5, is_dup_allow = true)
    current_category = InfoAndSetting.current_category
    query = self.get_query_for_active_tradeyas
    if not current_category.blank?
      tods_by_cat = Item.find(:all,
                              :conditions =>  query + " AND category_id = " + current_category.to_s,
                              :order => "created_at DESC",
                              :limit => limit)
    else
      tods_by_cat = nil
    end

    if (not tods_by_cat.blank?) and (tods_by_cat.count < 5)
      new_current_category = InfoAndSetting.change_current_category
      if new_current_category != current_category
        if not current_category.blank?
          tods_by_cat = Item.find(:all, :conditions =>  query + " AND category_id = " + current_category.to_s, :order => "created_at DESC", :limit => limit)
        else
          tods_by_cat = nil
        end
      end
    end
    tods_by_cat = Item.check_default_case(tods_by_cat)
    return tods_by_cat
  end

  def self.featured_tradeyas(limit=5,is_dup_allow = true,page=nil, ignore_uids=[])
    featured_tradeyas = FeaturedTradeya.current_featured_list
    featured_list = ''
    featured_tradeyas.each do |i|
      featured_list = (featured_list == '') ? i.item_id.to_s : featured_list + ',' + i.item_id.to_s
    end
    if featured_list.length > 0
      query = self.get_query_for_active_tradeyas
      if page
        tods = Item.paginate(:conditions => [query + " AND ID IN (#{featured_list})"], :order => "created_at DESC", :page => page)
        return tods
      else
        tods = Item.find(:all, :conditions => [query + " AND ID IN (#{featured_list})"], :order => "created_at DESC", :limit => limit)
      end
    end
    if tods.nil? then tods = [] end
    if tods.length < 5
      ft_ids = []
      tods.each do |tod|
        ft_ids[ft_ids.count] = tod.id
        ignore_uids[ignore_uids.count] = tod.user_id
      end
      tmp_tods = FeaturedTradeya.make_featured_tradeyas((5 - tods.length), ft_ids, ignore_uids)
      if tods.length == 0
        tods = tmp_tods
      else
        tmp_tods.each do |tod|
          tods[tods.count] = tod
        end
      end
    end
    # tods = check_default_case(tods,limit,is_dup_allow)
    return tods
  end

  def self.goods_tradeyas(limit = 5, is_dup_allow =true, ignore_uids = '')
    goods_categories = Category.goods
    category_list = nil
    goods_categories.each do |i|
      category_list = (category_list.nil?) ? i.id.to_s : category_list + ',' + i.id.to_s
    end
    query = self.get_query_for_active_tradeyas + " AND category_id IN (#{category_list}) "
    if ignore_uids.length > 0
      query = query + " AND user_id NOT IN (#{ignore_uids}) "
    end
    if limit
      tods = Item.find(:all, :conditions => query, :order => "created_at DESC", :limit => limit)
    else
      tods = Item.find(:all, :conditions => query, :order => "created_at DESC")
    end
    # tods = check_default_case(tods)
    return tods
  end

  def self.services_tradeyas(limit = 5, is_dup_allow = true, ignore_uids = '')
    services_categories = Category.services
    category_list = nil
    services_categories.each do |i|
      category_list = (category_list.nil?) ? i.id.to_s : category_list + ',' + i.id.to_s
    end
    query = self.get_query_for_active_tradeyas + " AND category_id IN (#{category_list}) "
    if ignore_uids.length > 0
      query = query + " AND user_id NOT IN (#{ignore_uids}) "
    end
    if limit
      tods = Item.find(:all, :conditions => query, :order => "created_at DESC", :limit => limit)
    else
      tods = Item.find(:all, :conditions => query, :order => "created_at DESC")
    end
    # tods = check_default_case(tods)

    return tods
  end

  def self.carousel_navigation(selected_option=1, limit = 5)
    case selected_option.to_i
    when 1; return @tradeyas = Item.check_default_case(Item.find_by_ids(InfoAndSetting.featured_tradeyas))
    when 2; return @tradeyas = Item.check_default_case(Item.find_by_ids(InfoAndSetting.newest_tradeyas))
    when 3; return @tradeyas = Item.check_default_case(Item.find_by_ids(InfoAndSetting.goods_tradeyas))
    when 4; return @tradeyas = Item.check_default_case(Item.find_by_ids(InfoAndSetting.services_tradeyas))
    end
  end

  def self.all_next_tods
    t = self.tod
    today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    tods = Item.find(:all, :conditions => ["tod = true AND (exp_date > " + "'" + today + "' OR exp_date IS NULL) AND id != " + t.id.to_s], :order => "exp_date ASC")
    return tods
  end

  def self.selected_tradeyas
    today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    tods = Item.find(:all, :conditions => ["tod = true AND exp_date > " + "'" + today + "'"], :order => "exp_date ASC")
    return tods
  end

  def self.next_tods(limit = 25)
    t = self.tod
    today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    tods = Item.find(:all, :conditions => ["tod = true AND (exp_date > " + "'" + today + "' OR exp_date IS NULL) AND id != " + t.id.to_s], :order => "exp_date ASC", :limit => limit)
    return tods
  end

  def self.all_prev_tod
    t = self.tod
    today = t.exp_date.utc.strftime("%Y-%m-%d %H:%M:%S")
    tods = Item.find(:all, :conditions => ["tod = true AND exp_date <= " + "'" + today + "'"], :order => "exp_date DESC")
    return tods
  end

  def self.prev_tod(limit = 5)
    t = self.tod
    today = t.exp_date.utc.strftime("%Y-%m-%d %H:%M:%S")
    tods = Item.find(:all, :conditions => ["tod = true AND exp_date <= " + "'" + today + "'"], :order => "exp_date DESC", :limit => limit)
    return tods
  end

  # For Small Item Card Images
  def item_image(size = "medium")
    if category.present?
      case category_id
        # Goods Start
      # default goods image
      when 2001..2099
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/goods_default.png"
      # old
      when 4
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/art&collect.png"
      when 5
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/clothingjewellery.png"
      when 6
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/electronic.png"
      when 7
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/furniture.png"
      when 8
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/miscellaneous.png"
      when 479
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/handmade.png"
      when 9
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/housing.png"
      when 10
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/mediaentertain.png"
      when 11
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/office_photos.png"
      when 13
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/tickets.png"
      when 14
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/vehicle_parts.png"
        # Goods End
        # Services Start
        # default services image
      when 3001..3099
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/services_default.png"
      # old
      when 15
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/accounting.png"
      when 16
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/architect.png"
      when 17
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/mediawebdesign.png"
      when 18
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/beauty_fitness.png"
      when 19
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/business_consulting.png"
      when 20
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/therapist.png"
      when 22
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/book_education.png"
      when 23
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/food&nutrition.png"
      when 24
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/other_services.png"
      when 25
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/programmers.png"
      when 26
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/vehicle-repair.png"
        # Services End
        # Housing Start
        # default housing image
      when 4001..4099
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Small/housing_default.png"
        # Housing End

      else
        src = "https://s3.amazonaws.com/tradeya_prod/tradeya/images/default_img.png"
      end
    else
      src = "https://s3.amazonaws.com/tradeya_prod/tradeya/images/default_img.png"
    end
    #src = "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/default_img.png"
    #photos = item_photos
    photos = item_photos.where(main_photo: true)
    if photos.present?
      src = photos[0].photo(size)
    elsif item_photos.count > 0
      photos = item_photos
      src = photos[0].photo(size)
    end
    return src
  end

  def item_image_height(size = "medium")
    if category.present?
      case category_id
        # Goods Start
      when 4
        src = 174
      when 5
        src = 174
      when 6
        src = 174
      when 7
        src = 146
      when 8
        src = 170
      when 479
        src = 175
      when 9
        src = 145
      when 10
        src = 145
      when 11
        src = 170
      when 13
        src = 173
      when 14
        src = 105
        # Goods End
        # Services Start
      when 15
        src = 120
      when 16
        src = 177
      when 17
        src = 175
      when 18
        src = 174
      when 19
        src = 174
      when 20
        src = 166
      when 22
        src = 174
      when 23
        src = 174
      when 24
        src = 170
      when 25
        src = 170
      when 26
        src = 173
        # Services End
      else
        src = 173
      end
    else
      src = 173
    end
    #src = "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/default_img.png"
    #photos = item_photos
    photos = item_photos.where(main_photo: true)
    if photos.present?
      src = (photos[0].height*225) / photos[0].width
      # src = photos[0].height
    elsif item_photos.count > 0
      photos = item_photos
      src = (photos[0].height*225) / photos[0].width
    end
    return src.round
  end

  # For Item Page Large Image
  def item_page_image(size = "medium")
    if category.present?
      case category_id
        # Goods Start
      # default goods image
      when 2001..2099
        src = "http://d3md9h2ro575fr.cloudfront.net/images/goods_default.png"
      # old
      when 4
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Art&collect1.png"
      when 5
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Clothing-jewellery-accrs1.png"
      when 6
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Electronic1.png"
      when 7
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Furniture1.png"
      when 8
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Misc1.png"
      when 479
        src = "http://d3md9h2ro575fr.cloudfront.net/images/icon-handmade1.png"
      when 9
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Housing&vacation1.png"
      when 10
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Media_entertain1.png"
      when 11
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Office_photos1.png"
      when 13
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Tickets&Coupons1.png"
      when 14
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Vehicles_parts1.png"
        # Goods End
        # Services Start
      # default services image
      when 3001..3099
        src = "http://d3md9h2ro575fr.cloudfront.net/images/services_default.png"
      # old
      when 15
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Accounting_finance2.png"
      when 16
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Architect1.png"
      when 17
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Media_webdesign1.png"
      when 18
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Beauty_fitness1.png"
      when 19
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Business_consulting1.png"
      when 20
        src = "http://d3md9h2ro575fr.cloudfront.net/images/therapist1.png"
      when 22
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Bookeducation1.png"
      when 23
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Food&nutrition1.png"
      when 24
        src = "http://d3md9h2ro575fr.cloudfront.net/images/other-services1.png"
      when 25
        src = "http://d3md9h2ro575fr.cloudfront.net/images/programmers1.png"
      when 26
        src = "http://d3md9h2ro575fr.cloudfront.net/images/Vehicle-repair1.png"
        # Services End
      # default housing image
      when 4001..4099
        src = "http://d3md9h2ro575fr.cloudfront.net/images/housing_default.png"
      else
        src = "https://s3.amazonaws.com/tradeya_prod/tradeya/images/default_img.png"
      end
    else
      src = "https://s3.amazonaws.com/tradeya_prod/tradeya/images/default_img.png"
    end
    #src = "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/default_img.png"
    #photos = item_photos
    photos = item_photos.where(main_photo: true)
    if photos.present?
      src = photos[0].photo(size)
    elsif item_photos.count > 0
      photos = item_photos
      src = photos[0].photo(size)
    end
    return src
  end

  def item_all_image(size = "medium")
    # default image code
    src = "https://s3.amazonaws.com/tradeya_prod/tradeya/images/default_img.png"
    #src = "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/default_img.png"
    src = []
    if item_photos.count > 0
      item_photos.by_main_photo.each do |ph|
        src[src.count] = ph.photo(size)
      end
    end
    return src
  end

  def item_image_full
    src = "https://s3.amazonaws.com/tradeya_stg_2/tradeya/images/default_img.png"
    if item_photos.count > 0
      photos = item_photos.where(main_photo: true)
      if photos.present?
        src = photos[0].photo(:large)
      else
        src = item_photos[0].photo(:large)
      end
    end
    return src
  end

  def isImgAutoWidth
    if item_photos.count > 0
      return item_photos[0].isImgAutoWidth
    else
      return false
    end
  end

  def category_title
    if self.category.nil? or self.category_id.nil?
      return nil
    else
      return category.title
    end
  end

  def offer_open4cats(to_s = true)
    cats = ((to_s) ? Hash.new : [])
    if not is_open_to_all_offers and not open4categories.blank?
      cat_ids = Category.find(:all, :conditions => ['id IN (' + open4categories + ')'])
      if to_s
        goods = []
        services = []
        cat_ids.each do |c|
          if c.category_id == 2 then goods.push(c.name) elsif c.category_id == 3 then services.push(c.name) end
        end
        cats.store("GOODS",goods) unless goods.length == 0
        cats.store("SERVICES",services) unless services.length == 0
      else
        cats = cat_ids
      end
    end

    return cats
  end

  def item_url
    if user.title.present?
      u_title = user.title
    else
      u_title = ""
    end
    u_title = u_title.gsub(/\s+/, "-").gsub(/\.+/, "")
    u_title = u_title.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
    u_title = u_title.encode!('UTF-8', 'UTF-16')
    u_title = u_title.gsub(/[^0-9A-Za-z\-,+()]/, '')

    t_title = title.gsub(/\s+/, "-").gsub(/\.+/, "").gsub(/\/+/, "-").gsub(/\?+/, "-").gsub(/\"+/, "")
    t_title = t_title.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
    t_title = t_title.encode!('UTF-8', 'UTF-16')
    t_title = t_title.gsub(/[^0-9A-Za-z\-,+()]/, '')

    u_loc = user.location.gsub(/, /, ",").gsub(/\s+/, "-").gsub(/\.+/, "")
    u_loc = u_loc.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
    u_loc = u_loc.encode!('UTF-8', 'UTF-16')
    u_loc = u_loc.gsub(/[^0-9A-Za-z\-,+()]/, '')

    # return 'http://' + Tradeya::Application.config.action_mailer.default_url_options[:host] + '/' + id.to_s + '/' + category.parent.name.gsub(/\s+/, "-").gsub(/\.+/, "-") + '/' + category.name.gsub(/, /, ",").gsub(/\s+/, "-").gsub(/\.+/, "") + '/' + t_title + '/' + u_loc + '/' + u_title + "/"
    if category.present?
      return 'http://' + Tradeya::Application.config.action_mailer.default_url_options[:host] + '/' + id.to_s + '/' + category.parent.name.gsub(/\s+/, "-").gsub(/\.+/, "-") + '/' + category.name.gsub(/, /, ",").gsub(/\s+/, "-").gsub(/\.+/, "").gsub("/","") + '/' + t_title + '/' + u_loc + '/' + u_title + "/"
    else
      return 'http://' + Tradeya::Application.config.action_mailer.default_url_options[:host] + '/' + id.to_s + '/' + t_title + '/' + u_loc + '/' + u_title + "/"
    end
  end

  def pl_url
    return Rails.application.routes.url_helpers.item_url(id, :host => Tradeya::Application.config.action_mailer.default_url_options[:host]) + Item.pl_url_sep + pl_url_suffix
  end

  def pl_url_suffix
    # return truncate(title.gsub(/\s+/, "").gsub(/-/, "").gsub(/"/, "").gsub(/'/, ""), :length => 5, :omission => '').downcase
    return truncate(title.gsub(/[^0-9A-Za-z]/, ''), :length => 5, :omission => '').downcase
  end

  def self.pl_url_sep
    return '-'
  end

  def self.get_live_tradeyas(category = nil, user_id = nil,page=nil,search_result=nil)
    # today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    basequery = "select i.* from items i, users u where tod = true and exp_date is not null and (status is null or status = 'LIVE')  and (quantity > 0 or qty_unlimited = true) and i.user_id = u.id and u.active = true"
    if category.present? then basequery = "#{basequery} and category_id =#{category}" end
    if user_id.present? then basequery = "#{basequery} and i.user_id = #{user_id}" end
    if search_result.present? then basequery = "#{basequery} and i.id IN (#{search_result})" end
    basequery = "#{basequery} order by created_at DESC"
    if page
      tods = self.paginate_by_sql(basequery, :page => page)
    else
      tods = self.find_by_sql(basequery)
    end
    return tods
  end

  def self.get_completed_tradeyas(category = nil, user_id = nil, featured = false, page=nil,search_result=nil)
    finaldata = Array.new
    # today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    basequery = "select i.*,tr.offer_id as trade_by,acc.created_at as cmp_date from items i,trades tr, accepted_offers acc, users u where i.id = tr.`item_id` and tr.id = acc.trade_id and i.user_id = u.id and u.active = true"
    if category.present? then basequery = "#{basequery} and i.category_id = #{category}" end
    if user_id.present? then basequery = "#{basequery} and i.user_id = #{user_id}" end
    if featured then basequery = "#{basequery} and i.is_featured = true" end
    if search_result.present? then basequery = "#{basequery} and i.id IN (#{search_result})" end
    basequery = "#{basequery} and i.tod = true and i.status = 'COMPLETED' and tr.id in (select trade_id from accepted_offers) and acc.user_id is not null group by i.id order by acc.created_at desc"
    if page
      tmpdata = self.paginate_by_sql(basequery, :page => page)
    else
      tmpdata = self.find_by_sql(basequery)
    end
    # tmpdata = User.filter_by_user(tmpdata)
    if tmpdata and tmpdata.count > 0
      tmpdata.each do |x|
        tmp = [0,0,0,0,0]
        tmp[0] = self.find(x.id)
        tmp[1] = self.find(x.trade_by)
        tmp[2] = Trade.total_offers(x.id)
        tmp[3] = AcceptedOffer.total_accepted(x.id)
        tmp[4] = x.cmp_date
        finaldata.push(tmp)
      end
    end
    if page
      return finaldata,tmpdata.total_entries
    else
      return finaldata
    end
  end

  def self.get_query_for_active_tradeyas
    return ACTIVE_TRADEYAS
    # today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    # return ACTIVE_TRADEYAS.sub("TODAY",today)
  end

  def self.get_newest_tradeyas(limit  = nil,page = nil, ignore_uids = '')
    # today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    basequery = "select i.* from items i, users u where i.tod = true and (i.quantity > 0 or i.qty_unlimited = true) and (i.status is NULL or i.status = 'LIVE') and i.user_id = u.id and u.active = true "
    if ignore_uids.length > 0
      basequery = basequery + " and i.user_id not in (#{ignore_uids}) "
    end
    basequery = basequery + " order by i.created_at DESC"
    if limit
      basequery = basequery + " limit #{limit}"
      tods = self.find_by_sql(basequery)
    elsif page
      tods = self.paginate_by_sql(basequery, :page => page)
    else
      tods = self.find_by_sql(basequery)
    end
    # return User.filter_by_user(tods)
    return tods
  end

  def self.get_user_tradeyas(id, order = nil, page = nil)
    # today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    basequery = "select i.* from items i, users u where i.tod = true and (i.quantity > 0 or i.qty_unlimited = true) and (i.status is NULL or i.status = 'LIVE' or i.status = 'INCOMPLETE') and i.user_id = #{id} and i.user_id = u.id and u.active = true order by i.created_at DESC"
    basequery = basequery + " " + order if !order.nil?
    if page
      # startLimit = (page-1)*RECORDS_PER_PAGE
      # basequery = "#{basequery} limit #{startLimit},#{RECORDS_PER_PAGE}"
      tods = self.paginate_by_sql(basequery, :page => page)
    else
      tods = self.find_by_sql(basequery)
    end
    # return User.filter_by_user(tods)
    return tods
  end

  def self.get_user_tradeyas_count(id)
    # today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    return Item.count(:conditions => "tod = true and (quantity > 0 or qty_unlimited = true) and (status is NULL or status = 'LIVE' or status = 'INCOMPLETE') and user_id = #{id}")
  end

  def self.get_user_offers(id, page = nil)
    # today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    basequery = "select i.* from items i, users u where i.id in (select item_id from trades where offer_id in (select id from items where user_id = #{id}) and status != 'DELETED') and (i.quantity > 0 or i.qty_unlimited = true) and i.status = 'LIVE' and i.user_id = u.id and u.active = true order by i.created_at DESC"
    if page
      tods = self.paginate_by_sql(basequery, :page => page)
      # startLimit = (page-1)*RECORDS_PER_PAGE
      # basequery = "#{basequery} limit #{startLimit},#{RECORDS_PER_PAGE}"
    else
      tods = self.find_by_sql(basequery)
    end
    # return User.filter_by_user(tods)
    return tods
  end

  def self.get_completed_offers(user_id,page = nil)
    finaldata = Array.new;item_ids="";cmpltd_items=Array.new;
    # today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    basequery = "select i.*,tr.item_id as tradeya,acc.created_at as cmp_date from items i,trades tr, accepted_offers acc, users u where i.id = tr.`offer_id` and tr.id = acc.trade_id and tr.status != 'DELETED' and i.user_id = u.id and u.active = true"
    if user_id.present? then basequery = "#{basequery} and i.user_id = #{user_id}" end
    basequery = "#{basequery} and tr.id in (select trade_id from accepted_offers) group by tr.item_id order by acc.created_at desc"
    if page
      tmpdata = self.paginate_by_sql(basequery, :page => page)
    else
      tmpdata = self.find_by_sql(basequery)
    end
    # tmpdata = User.filter_by_user(tmpdata)
    if tmpdata and tmpdata.count > 0
      tmpdata.each do |x|
        item_ids = item_ids.blank? ? "#{x.tradeya}" : "#{item_ids},#{x.tradeya}"
      end
      if item_ids.present?
        tods = self.find_by_sql("select * from items where id in (#{item_ids}) and status = 'COMPLETED'")
        tods.each do |x|
          cmpltd_items.push(x.id)
        end
      end
      tmpdata.each do |x|
        if cmpltd_items.include?(x.tradeya)
          tmp = [0,0,0,0,0]
          tmp[0] = self.find(x.tradeya)
          tmp[1] = self.find(x.id)
          tmp[2] = Trade.total_offers(x.tradeya)
          tmp[3] = AcceptedOffer.total_accepted(x.tradeya)
          tmp[4] = x.cmp_date
          finaldata.push(tmp)
        end
      end
    end
    if page
      return finaldata ,tmpdata.total_entries
    else
      return finaldata
    end
  end

  def self.get_featured_tradeyas(page)
    return featured_tradeyas(nil,false,page)
    # today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    # return self.find_by_sql("select * from items where tod = true and is_featured = true and exp_date > '#{today}' order by created_at desc")
  end

  # def self.search_by_zipcode(zipcode,usrll)
  #   finaldata = [0,0,0,0];live=Array.new;completed=Array.new;distance=Hash.new;comp_distance=Hash.new;
  #   origin = ""
  #   begin
  #     origin = Geokit::Geocoders::MultiGeocoder.geocode(zipcode)
  #   rescue
  #     origin = Geokit::Geocoders::MultiGeocoder.geocode(zipcode)
  #   end
  #   if !origin.blank?
  #     get_live_tradeyas(nil).each do |item|
  #       usr = item.user
  #       if usr.lat.present? and usr.lng.present?
  #         dist = ""
  #         begin
  #           dist = origin.distance_to([usr.lat,usr.lng])
  #         rescue
  #           dist = 9999
  #         end
  #         if dist.round(1) <= SEARCH_ZIP_RADIUS
  #           distance[item.id] = dist.round(1)
  #           live.push(item)
  #         end
  #       end
  #     end
  #     # get_completed_tradeyas(nil).each do |cmp|
  #     #   usr = cmp[0].user
  #     #   if usr.lat.present? and usr.lng.present?
  #     #     dist = ""
  #     #     begin
  #     #       dist = origin.distance_to([usr.lat,usr.lng])
  #     #     rescue
  #     #       dist = 9999
  #     #     end
  #     #     if dist.round(1) <= SEARCH_ZIP_RADIUS
  #     #       comp_distance[cmp[0].id] = dist.round(1)
  #     #       completed.push(cmp)
  #     #     end
  #     #   end
  #     # end
  #   end
  #   finaldata[0] = live;finaldata[1] = completed;finaldata[2] = distance;finaldata[3] = comp_distance;
  #   return finaldata
  # end

  def self.isNumber(str)
    true if Float(str) rescue false
  end

  def self.check_default_case(tods,limit = 5,is_dup_allow = true)
    if tods.nil? || tods.length == 0
      tods = Item.last
    end

    if is_dup_allow
      if tods.count < limit
        c = 0
        r = tods.count
        ((tods.count)..(limit - 1)).each do |i|
          tods[i] = tods[c]
          if c < r then c = c + 1 else c = 0 end
        end
      end
    end

    return tods
  end

  def self.get_items(trade_ids)
    if trade_ids.present?
      tods = self.find_by_sql("select * from items where id in (select offer_id from trades where id in (#{trade_ids}))")
      return User.filter_by_user(tods)
    else
      return []
    end
  end

  def reduce_quantity
    if !self.qty_unlimited
      self.quantity = self.quantity - 1 if self.quantity.present?
      if self.quantity.blank? or self.quantity <= 0
        self.status = 'COMPLETED'
        if self.user.notify_tradeya_complete then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_COMPLETED, self.user.id, {:item_id => id}) end
        unaccepted_trades = self.trades.activeOffers
        unaccepted_trades.each do |trd|
          # Alert.add_2_alert_q(ALERT_TYPE_OFFER, OFFER_NOT_ACCEPTED, trd.offer.user.id, nil, trd.id)
          # offer turned invalid
          # if trd.offer.user.notify_offer_turned_invalid then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_COMPLETED, trd.offer.user.id, {:item_id => @item.id}) end
        end
      end
      self.save
    end
  end

  def complete_trade
    if self.user.notify_tradeya_complete then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_COMPLETED, self.user.id, {:item_id => id}) end
    self.trades.each do |trd|
      if trd.accepted_offer.nil? and not trd.offer_deleted?
        # Alert.add_2_alert_q(ALERT_TYPE_OFFER, OFFER_NOT_ACCEPTED, trd.offer.user.id, nil, trd.id)
        # offer turned invalid
        # if trd.offer.user.notify_offer_turned_invalid then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_COMPLETED, trd.offer.user.id, {:item_id => @item.id}) end
      end
    end

    return self.update_attribute("status", "COMPLETED")
  end

  def live?
    return (status == nil or status == 'LIVE')
  end

  def postponed?
    return (status == 'POSTPONED')
  end

  def expired?
    return (status == 'EXPIRED' or (status != 'POSTPONED' and status != 'DELETED' and not exp_date.nil? and exp_date < Time.zone.now and accepted_trades.length < 1))
  end

  def completed?
    return (status == 'COMPLETED')
  end

  def incomplete?
    return (status == 'INCOMPLETE')
  end

  # todo - review query
  def accepted_offers
    return self.trades.traded
    # trds = Trade.find_by_sql("select * from trades where id in (select trade_id from accepted_offers) and item_id = #{self.id}")

  end

  def accepted_trades
    return Trade.find_by_sql("select * from trades where id in (select trade_id from accepted_offers) and item_id = #{self.id}")
    # return Trade.find_by_sql("select * from trades where item_id = #{self.id} and id in (select trade_id from accepted_offers where trade_id in (select id from trades where item_id = #{self.id}))")
  end

  # ToDo - review query
  def rejected_offers
    trds = self.trades.where(:status => "REJECTED")
    trds.collect{|of| Item.find_by_id(of.offer_id)} if trds.present?
  end

  def other_trades
    trds = Trade.find_by_sql("select * from trades where (status != 'DELETED' OR status = 'REJECTED' OR status IS NULL) and id not in (select trade_id from accepted_offers) and item_id = #{self.id}")
    trds.collect{|of| Item.find_by_id(of.offer_id)} if trds.present?
    #trds = Trade.find_by_sql("select * from trades where item_id = #{self.id} AND (status != 'DELETED' OR status IS NULL) and id not in (select trade_id from accepted_offers where trade_id in (select id from trades where item_id = #{self.id}))")
    # return User.filter_by_user(trds)
  end

  # TODO - change the query
  def current_offers
    # trade should be active + items/offers should be live
    # trds = Trade.find_by_sql("select * from trades where (status != 'ACCEPTED' OR status != 'DELETED' OR status != 'REJECTED' OR status IS NULL) and id not in (select trade_id from accepted_offers) and item_id = #{self.id}")
    return self.trades.where('(id not in (select trade_id from accepted_offers)) and (status != "ACCEPTED" and status != "DELETED" and status != "REJECTED")').includes(:offer)
    # trds.collect{|of| Item.find_by_id(of.offer_id)} if trds.present?
  end

  # def total_trades
  #   # offer = []
  #   # offer = accepted_trades
  #   # offer.concat(other_trades)
  #   # return offer
  # end

  #-----------------------------------------------------------------------------#
  # total_trades ----> "Return sum of trades and reverse_trades for the item"
  # Params --- IN:
  # Params --- OUT:
  # +return+:: Trade objects
  #------------------------------------------------------------------------------#
  def total_trades
    t_ids = self.trades.pluck(:id)
    t_ids = t_ids + self.reverse_trades.pluck(:id)
    if t_ids.present?
      return Trade.where(:id => t_ids).order_by_latest.includes({item: :user},{offer: :user})
    else
      return nil
    end
  end
  #-----------------------------------------------------------------------------#
  # total_active_trades ----> "Return sum of trades and reverse_trades for the item which are still active"
  # Params --- IN:
  # Params --- OUT:
  # +return+:: Trade objects
  #------------------------------------------------------------------------------#
  def total_active_trades
    t_ids = self.trades.with_live_offer.pluck(:id)
    t_ids = t_ids + self.reverse_trades.with_live_item.pluck(:id)
    if t_ids.present?
      return Trade.where(:id => t_ids).active.order_by_latest.includes({item: :user},{offer: :user})
    else
      return nil
    end
  end

  def total_active_trades_by_user(user_id)
  end
  #-----------------------------------------------------------------------------#
  # total_accepted_trades ----> "Return sum of trades and reverse_trades for the item which are accepted"
  # Params --- IN:
  # Params --- OUT:
  # +return+:: Trade objects
  #------------------------------------------------------------------------------#
  def total_accepted_trades
    trades = self.total_trades
    if trades
      return trades.traded.includes({item: [:user, :item_photos]},{offer: [:user, :item_photos]})
    else
      nil
    end
  end

  # TODO - those tradeyas which have 'EXPIRED' status, change them to LIVE
  def item_status
    item_status = 0
    if deleted?
      return 0
    end
    # returns the status as well as updates the value of status of the item in case it is needed to be changed
    if live? then item_status = ACTIVE
    elsif status == 'POSTPONED' then item_status = POSTPONED
      # elsif status == 'EXPIRED' or (exp_date < Time.zone.now and accepted_trades.length < 1) then
      #   item_status = EXPIRED
      #   update_attribute("status", "EXPIRED") unless status == 'EXPIRED'
    elsif status == "COMPLETED" or quantity <= 0 then
      item_status = COMPLETED
    end
    return item_status
  end

  def deleted?
    return status == "DELETED" ? true : false
  end

  def self.calculate_distance(items, usrll)
    distance = Hash.new;
    origin = ""
    begin
      origin = Geokit::LatLng.normalize(usrll)
    rescue
      origin = Geokit::LatLng.normalize(usrll)
    end
    if origin.present?
      items.each do |item|
        usr = item.user
        if usr.lat and usr.lat.present? and usr.lng and usr.lng.present?
          dist = ""
          begin
            dist = origin.distance_to([usr.lat,usr.lng])
          rescue
            dist = 9999
          end
          # if dist.round(1) <= SEARCH_ZIP_RADIUS
          distance[item.id] = dist.round(1)
          # end
        end
      end
    end
    return distance
  end

  def page_keywords
    pt = "Barter, Swap, Trade"

    if not self.id.nil?
      cat = self.category
      if cat.nil? or self.category_id.nil?
        return pt
      else
        return  pt = pt + ", " + cat.parent.name + ", " + cat.name.gsub(", ", " ").gsub(",", " ") + ", " + self.title.gsub(", ", " ").gsub(",", " ") + ((self.user.full_location == '-') ? "" : (", " + self.user.full_location))
      end
    end
  end

  def self.get_tradeya_history(user_id)
    # today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    # tods = self.find_by_sql("select * from items where (status != 'LIVE' and status != 'ACTIVE' and status != 'DELETED') and tod = true and user_id = #{user_id} order by updated_at desc")
    tods = self.find_by_sql("select * from items where (status = 'COMPLETED' or status = 'POSTPONED') and status != 'DELETED' and tod = true and user_id = #{user_id} order by updated_at desc")
    return User.filter_by_user(tods)
  end

  def comments_by_others
    return Comment.find_by_sql("select count(*) as total from comments where item_id = #{id} and user_id != #{user.id}")[0].total
  end

  def self.postpone_trade(id)
    begin
      item = self.find(id)
      item.update_attribute("status","POSTPONED")
      item.trades.each do |trd|
        # EventNotificationMailer.tradeya_postponed(item,trd.offer).deliver
        if !trd.offer_deleted?
          if trd.offer.user.notify_tradeya_postponed_reactivated then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_TRADEYA_POSTPONED, trd.offer.user.id, {:trade_id => trd.id}) end
        end
      end
      return true
    rescue
      return false
    end
  end

  # TODO - remove this call alltogether as there is no expired logic anymore
  def self.tradeya_going2expire(u = nil, other_person_tradeya = false, ignore_list=nil)
    query = self.get_query_for_active_tradeyas
    query = query + " AND id NOT IN (" + ignore_list + ") " unless ignore_list.nil?
    if u.nil?
      return Item.find(:first, :conditions =>  query, :order => "exp_date ASC")
    elsif other_person_tradeya
      return Item.find(:first, :conditions =>  query + " AND user_id != " + u.id.to_s, :order => "exp_date ASC")
    else
      return Item.find(:first, :conditions =>  query + " AND user_id = " + u.id.to_s, :order => "exp_date ASC")
    end
  end
  # def self.get_completed_featured_tradeyas(category = nil,user_id = nil)
  #   finaldata = Array.new
  #   item_ids = FeaturedTradeya.completed_featured_list
  #   if !item_ids.blank?
  #     today = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
  #     basequery = "select i.*,tr.offer_id as trade_by,acc.created_at as cmp_date from items i,trades tr, accepted_offers acc where i.id = tr.`item_id` and tr.id = acc.trade_id"
  #     if category.present? then basequery = "#{basequery} and i.category_id = #{category}" end
  #     if user_id.present? then basequery = "#{basequery} and i.user_id = #{user_id}" end
  #     basequery = "#{basequery} and i.tod = true and (i.exp_date < '#{today}' or i.status = 'COMPLETED') and i.id in (#{item_ids}) and tr.id in (select trade_id from accepted_offers) and acc.user_id is not null group by i.id order by acc.created_at desc"
  #     tmpdata = self.find_by_sql(basequery)
  #     tmpdata = User.filter_by_user(tmpdata)
  #     if tmpdata and tmpdata.count > 0
  #       tmpdata.each do |x|
  #         tmp = [0,0,0,0,0]
  #         tmp[0] = self.find(x.id)
  #         tmp[1] = self.find(x.trade_by)
  #         tmp[2] = Trade.total_offers(x.id)
  #         tmp[3] = AcceptedOffer.total_accepted(x.id)
  #         tmp[4] = x.cmp_date
  #         finaldata.push(tmp)
  #       end
  #     end
  #   end
  #   return finaldata
  # end

  # TODO - see where this is being called - remove
  def time_remaining
    now = Time.zone.now
    diff = now - self.exp_date

    secs = (diff % 60).to_i
    mins  = ((diff / 60)%60).to_i
    hours = ((diff /(60*60))%24).to_i
    days  = (diff / (24*60*60)).to_i
             time = ""
             if days == 1 then time += "1 Day"
             elsif days > 1 then time += "#{days} Days"
             end
             if hours == 1 then time += " 01"
             elsif hours == 0 then time += " 00"
             else
               time += ((hours < 10) ? " 0#{hours}" : " #{hours}")
             end
             time += ":"
             if mins == 1 then time += "01"
             elsif mins == 0 then time += "00"
             else
               time += ((mins < 10) ? "0#{mins}" : "#{mins}")
             end
             time += ":"
             if secs == 1 then time += "01"
             elsif secs == 0 then time += "00"
             else
               time += ((secs < 10) ? "0#{secs}" : "#{secs}")
             end
             return time
           end

# TODO - see where this is being called - remove
def days_remaining
  diff = self.exp_date - Time.zone.now
  days  = (diff / (24*60*60)).to_i
  return days
end

def self.find_by_ids(str)
  if !str.nil? and str.length > 0
    return self.find(:all, :conditions => " ID in (#{str}) ")
  else
    return []
  end
end

def user_can_offer(items,uid)
  result = []
  items.each do |itm|
    result[result.count] = itm.id unless (itm.user_id == uid)
  end
  return result
end


# TODO review the query
def active_offers_by_user(user_id)

  return Trade.joins("left outer join items on items.id = trades.item_id left outer join items as offers on offers.id = trades.offer_id")
    .where("((items.user_id = #{user_id} and offers.id = #{self.id}) or (items.id = #{self.id} and offers.user_id = #{user_id}))
                    and (items.status = 'LIVE' and offers.status = 'LIVE' and trades.status = 'ACTIVE')")
    .activeOffers.select("trades.*, items.user_id as item_user_id, offers.user_id as offer_user_id").order_by_latest
end

def want_cancelled(item_id,user_id)
  if item_id.present? and user_id.present?
    want =  Want.find_by_item_id_and_user_id(item_id, user_id)
    if want.present?
      return want.cancelled_wants
    end
  end
end

def get_short_title
  if self.title.length > 18
    return "#{self.title[0..18]}..."
  else
    return self.title
  end
end
end
