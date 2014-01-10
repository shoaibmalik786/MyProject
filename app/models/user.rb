class User < ActiveRecord::Base
  has_merit


  has_many :items, :dependent => :destroy
  has_many :authentications, :dependent => :destroy
  has_many :item_wants
  has_many :user_photos, :dependent => :destroy
  has_many :accepted_offers, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :reviews, :class_name => "Review", :foreign_key=>"reviewee_id", :dependent => :destroy #reviews about user
  has_many :reviews_written, :class_name=>"Review", :foreign_key=> "reviewer_id", :dependent => :destroy #reviews written by user
  has_many :alerts, :dependent => :destroy
  has_many :event_notifications, :dependent => :destroy
  has_many :thumb_up_downs, :dependent => :destroy

  has_many :follows, :foreign_key => "follower_id", :dependent => :destroy
  has_many :followed_users, through: :follows, source: :followed
  has_many :reverse_follows, foreign_key: "followed_id", class_name: "Follow", dependent: :destroy
  has_many :followers, through: :reverse_follows

  has_many :haves, :class_name => "Have", :dependent => :destroy

  has_many :wants, :dependent => :destroy
  has_many :want_items, :through => :wants, :source => :item

  has_many :likes, :dependent => :destroy
  has_many :like_items, :through => :likes, :source => :item

  has_many :request_info_items , :dependent => :destroy

  has_many :invitations, :class_name => 'User', :as => :invited_by

  has_many :trades, :through => :items
  has_many :reverse_trades, :through => :items, :class_name => "Trade", :foreign_key => "offer_id"

  has_many :charge_cards
  has_many :addresses

  has_many :passive_trades
  has_many :trade_communications
  has_one :tracking_info, dependent: :destroy

  has_many :notification_devices
  
  has_many :tracking_infos, :dependent => :destroy #stores the affiliate id associated with the user
  
  # mailboxer
  acts_as_messageable

  # mailboxer
  def name
    return :email
  end

  # mailboxer
  def mailboxer_email(object)
    return self.email
  end

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable,
  # :timeoutable and :omniauthable, :validatable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
    :recoverable, :rememberable, :trackable, :validatable, :lockable
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,:about,
    :first_name, :display_name, :last_name, :city, :state, :zip, :phone, :can_contact, :tod, :can_delete_item, :lat, :lng, :active,
    :gender, :tooltip, :notify_tradeya_begins,:notify_tradeya_timer,:notify_tradeya_over, :notify_received_offer,
    :notify_offer_changed, :notify_received_comments,:notify_offer_accepted, :notify_offer_turned_invalid, :notify_tradeya_complete,
    :notify_tradeya_expired_reactivated,:notify_tradeya_postponed_reactivated,:notify_tradeya_news_updates,:notification_frequency,
    :notify_via_email,:notify_via_mobile, :goods_sub_cat_ids, :services_sub_cat_ids, :interests_sub_cat_ids, :wish, :is_in_matching_q,
    :tradeya_match_ids, :person_match_ids, :is_guest_user, :goods_str, :services_str, :interests_str, :tradeya_count, :notify_tradeya_liked,
    :notify_tradeya_wanted, :notify_tradeya_wanted_traded, :notify_tradeya_liked_traded, :address, :children, :website, :dashboard_billboards, :shipping_notes

  # ajaxful_rater

  attr_accessor :profile_pic_later

  validates :email, :presence => true, :uniqueness => true
  validates :first_name, :presence => true
  # validates_format_of :first_name, :with => /\A[a-zA-Z0-9\s]++\D+\Z/
  #validates_format_of :first_name, :with => /^([a-zA-Z\s\-]*)$/

  before_save :ensure_authentication_token
  before_save :update_proflie_column

  scope :self_invites,
    where("invitation_token IS NOT NULL").where("invited_by_id IS NULL")

  searchable do
    text :first_name
    text :last_name
    text :city
    text :state
    text :zip
    text :display_name
    latlon (:location) { Sunspot::Util::Coordinates.new(self.lat, self.lng) if self.lat.present? and self.lng.present? }
    time :created_at
  end

  def to_s
    self.first_name
  end

  def to_param
    "#{id} #{location}".parameterize
  end

  def user_location
    return self.location
  end

  def self.user_search(search = nil, sort = nil, page = 1, usrll = nil, within = nil, perpage = nil)
    origin = usrll
    begin
      search = User.solr_search do

        if search.present?
          fulltext search
        end
        if sort.present?
          if sort == "distance" and origin.present?
            order_by_geodist(:location,origin[0],origin[1])
          else
            order_by(:created_at, :desc)
          end
        else
          order_by(:created_at, :desc)
        end
        if within.present?
          with(:location).in_radius(origin[0], origin[1], within) unless origin.nil?
        end
        if perpage.present?
          paginate :per_page => perpage, :page => page
        else
          paginate :per_page => 20, :page => page
        end
      end
    rescue StandardError => e
      search = nil
    end
    return search
  end

  def self.calculate_distance(users, usrll)
    distance = Hash.new;
    origin = ""
    begin
      origin = Geokit::LatLng.normalize(usrll)
    rescue
      origin = Geokit::LatLng.normalize(usrll)
    end
    if origin.present?
      users.each do |usr|
        if usr.lat and usr.lat.present? and usr.lng and usr.lng.present?
          dist = ""
          begin
            dist = origin.distance_to([usr.lat,usr.lng])
          rescue
            dist = 9999
          end
          # if dist.round(1) <= SEARCH_ZIP_RADIUS
          distance[usr.id] = dist.round(1)
          # end
        end
      end
    end
    return distance
  end

  # skip confirmation for user sign up from mobile
  def skip_confirmation!
    self.confirmed_at = Time.now
  end

  # TODO check this method can use or not
  def apply_omniauth(omniauth)
    if omniauth.provider == "twitter"
      self.email = "a" + Time.now.to_i.to_s + "@abc.com"
      self.first_name = omniauth['info']['nickname']
    else
      self.email = omniauth['info']['email'] if self.email.blank?
      self.first_name = omniauth['info']['first_name'] if self.first_name.blank?
      self.last_name = omniauth['info']['last_name'] if self.last_name.blank?
    end

    # if !omniauth['uid'].blank? and !omniauth['info']['email'].blank?
    if !omniauth['uid'].blank? 
      authentications.build(:provider => omniauth['provider'],
                            :uid => omniauth['uid'],
                            :access_token => omniauth.credentials.token,
                            :access_secret => omniauth.credentials.secret)
    end
  end

  def update_proflie_column
    if self.goods_sub_cat_ids_changed?
      self.goods_str = goods
    end
    if self.services_sub_cat_ids_changed?
      self.services_str = services
    end
    if self.interests_sub_cat_ids_changed?
      self.interests_str = interests
    end
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
    # if !persisted?
    #   !(password != "")
    # else
    #   (!password.nil? || !password_confirmation.nil? ||
    #     authentication.empty?) && super
    # end

  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  # bypass requirement for twitter users
  #   def email_required?
  # debugger
  #     (authentications.where(provider: 'twitter').empty? || !email.blank?) && super
  #   end

  def user_image(size = "thumb")
    src = "http://d3md9h2ro575fr.cloudfront.net/images/defaultuserimage.png"
    if self.active && self.user_photos.present?
      main_photos = user_photos.by_main_photo
      if main_photos.present?
        src = main_photos[0].photo(size)
      else
        src = self.user_photos[0].photo(size)
      end
    elsif self.active
      if self.authentications.size > 0
        uid = nil
        self.authentications.each do |a|
          if a.provider == 'facebook'
            uid = a.uid
          end
        end
        if uid != nil
          if size == "medium" or size == "large" or size == :large or size == :medium
            src = "https://graph.facebook.com/" + uid + "/picture?width=225&height=225"
          else
            src = "https://graph.facebook.com/" + uid + "/picture?type=square"
          end
        end
      end
    end
    return src
  end

  def user_all_image(size = "thumb")
    src = "http://d3md9h2ro575fr.cloudfront.net/images/defaultuserimage.png"
    src = []
    images = self.user_photos.limit(4).by_latest
    if images.count > 0
      images.each do |ph|
        src[src.count] = ph.photo(size)
      end
    end
    return src
  end

  def title
    if self.display_name.blank? and !self.first_name.blank?
      self.display_name = self.first_name
      self.save
    end
    # return self.display_name
    if self.first_name.blank?
      if self.display_name.blank?
        return " "
      else
        return self.display_name.capitalize
      end
    elsif self.last_name.blank?
      return self.first_name.capitalize
    else
      return self.first_name.capitalize + ' ' + self.last_name[0,1].capitalize + '.'
    end

  end

  def title_with_s
    # title = first_name + ((last_name.blank?) ? '' : ' ' + last_name)
    title = self.title
    if title[title.length - 1] != 's' then title = title + '\'s' else title = title + '\'' end

    return title
  end

  def first_name_with_s
    title = first_name_in_caps
    # title = ((first_name.present?)? first_name : (display_name.present?) ? display_name : "")
    if title[title.length - 1] != 's' then title = title + '\'s' else title = title + '\'' end
    return title
  end

  def first_name_in_caps
    title = ((first_name.present?)? first_name : (display_name.present?) ? display_name : "")
    return title.split(' ').map {|w| w.capitalize }.join(' ')
  end

  def location
    if city.blank? and state.blank?
      return '-'
    elsif city.blank?
      return state
    elsif state.blank?
      return city
    else
      return city + ', ' + state
    end
  end

  def full_location
    if city.blank? and state.blank? and zip.blank?
      return '-'
    else
      return (city.blank? ? "" : city.gsub(", ", " ").gsub(",", " ")) + (state.blank? ? "" : (city.blank? ? state : " " + state)) + (zip.blank? ? "" : ((city.blank? and state.blank?) ? zip : " " + zip))
    end
  end

  def pub?(tod = nil)
    if tod.nil?
      return Item.get_user_tradeyas(id).count > 0
    else
      return tod.user.id == id
    end
  end

  def tradeya
    tradeya = Item.get_user_tradeyas(id).first
    return tradeya
  end

  def user_tradeya_ids(to_s = true)
    tradeyas = Item.get_user_tradeyas(id)
    trds = (to_s)? "" : []
    tradeyas.each do |o|
      if o.user_id == id
        if to_s
          trds = trds + (trds.length > 0 ? "," : "") + o.id.to_s
        else
          trds[trds.count] = o.id
        end
      end
    end
    return trds
  end

  def offerer?(item_id)
    trades = Item.find(item_id).trades
    is_offerer = false
    trades.each do |t|
      if t.offer.user.id == id and t.offer.status != "DELETED"
        is_offerer = true
        break
      end
    end
    return is_offerer;
  end

  # publisher name link url
  def nl_url
    return '/' + first_name + ((last_name.blank?) ? '' : '.' + last_name)
  end

  def self.get_user_with_nolocation
    return self.find_by_sql("select * from users where (lat is null or lng is null) and (city is not null or state is not null or zip is not null)")
  end

  # TODO - change
  def self.get_user_reviews(user_id)
    # return self.reviews.all
    reviews = Review.find(:all,:conditions => "reviewee_id = #{user_id}")
    return reviews
  end

  def authentication(provider)
    return Authentication.find(:first, :conditions => {:user_id => id, :provider => provider, :verified => true})
  end

  def facebook_authenticated?
    return (Authentication.count(:conditions => {:user_id => id, :provider => 'facebook', :verified => true}) > 0)
  end

  def twitter_authenticated?
    return (Authentication.count(:conditions => {:user_id => id, :provider => 'twitter'}) > 0)
  end

  def linkedin_authenticated?
    return (Authentication.count(:conditions => {:user_id => id, :provider => 'linkedin'}) > 0)
  end

  def has_authentications?
    return (Authentication.count(:conditions => {:user_id => id}) > 0 or phone_verified?)
  end

  def phone_verified?
    return (PhoneNumber.count(:conditions => {:user_id => id, :verified => true}) > 0)
  end

  def verifications
    verifA = Array.new
    verifA << "phone" if self.phone_verified?
    self.authentications.each {|x| verifA << x.provider if x.verified} unless self.authentications.nil?
    return verifA
  end

  def phone_numbers
    return PhoneNumber.find(:all, :conditions => {:user_id => self.id, :verified => true})
  end

  # This checks if user is signed up through facebook only
  # User cannot change password on edit settings page
  # User cannot remove facebook verification from edit verifications page
  def facebook_user?
    return facebook_authenticated? #encrypted_password.blank?
  end

  # Facebook graph - Koala
  def facebook_graph
    @facebook_graph ||= Koala::Facebook::API.new(self.authentication("facebook").access_token)
  end

  def self.user_by_uid(uid)
    a = Authentication.find(:first, :conditions => {:uid => uid})
    return (a.nil? ? a : a.user)
  end

  def self.user_image_by_uid(uid)
    src = "https://s3.amazonaws.com/tradeya_prod/tradeya/images/TY_DefaultUser_sm.gif"
    if uid != nil
      src = "https://graph.facebook.com/" + uid + "/picture?type=normal"
    end
    return src
  end

  def self.filter_by_user(items)
    temp = []
    if items.count > 0
      if items[0].class.to_s == "Item"
        items.each do |tod|
          if tod.user.active
            temp[temp.count] = tod
          end
        end
      else
        items.each do |trd|

          if trd.offer.user and trd.offer.user.active
            temp[temp.count] = trd
          end

        end
      end
    end
    return temp
  end

  def isFacebookUser?
    return self.user_photo.nil?
  end

  def notify_tradeya_begins?(via)
    if via == MOBILE
      return (notify_via_mobile and notify_tradeya_begins)
    else
      return (notify_via_email and notify_tradeya_begins)
    end
  end

  def notify_tradeya_timer?(via)
    if via == MOBILE
      return (notify_via_mobile and notify_tradeya_timer)
    else
      return (notify_via_email and notify_tradeya_timer)
    end
  end

  def notify_tradeya_over?(via)
    if via == MOBILE
      return (notify_via_mobile and notify_tradeya_over)
    else
      return (notify_via_email and notify_tradeya_over)
    end
  end

  def notify_received_offer?(via)
    if via == MOBILE
      return (notify_via_mobile and notify_received_offer)
    else
      return (notify_via_email and notify_received_offer)
    end
  end

  def notify_offer_changed?(via)
    if via == MOBILE
      return (notify_via_mobile and notify_offer_changed)
    else
      return (notify_via_email and notify_offer_changed)
    end
  end

  def notify_received_comments?(via)
    if via == MOBILE
      return (notify_via_mobile and notify_received_comments)
    else
      return (notify_via_email and notify_received_comments)
    end
  end

  def notify_offer_accepted?(via)
    if via == MOBILE
      return (notify_via_mobile and notify_offer_accepted)
    else
      return (notify_via_email and notify_offer_accepted)
    end
  end

  def notify_offer_turned_invalid?(via)
    if via == MOBILE
      return (notify_via_mobile and notify_offer_turned_invalid)
    else
      return (notify_via_email and notify_offer_turned_invalid)
    end
  end

  def notify_tradeya_complete?(via)
    if via == MOBILE
      return (notify_via_mobile and notify_tradeya_complete)
    else
      return (notify_via_email and notify_tradeya_complete)
    end
  end

  def notify_tradeya_expired_reactivated?(via)
    if via == MOBILE
      return (notify_via_mobile and notify_tradeya_expired_reactivated)
    else
      return (notify_via_email and notify_tradeya_expired_reactivated)
    end
  end

  def notify_tradeya_postponed_reactivated?(via)
    if via == MOBILE
      return (notify_via_mobile and notify_tradeya_postponed_reactivated)
    else
      return (notify_via_email and notify_tradeya_postponed_reactivated)
    end
  end

  def notify_tradeya_news_updates?(via)
    if via == MOBILE
      return (notify_via_mobile and notify_tradeya_news_updates)
    else
      return (notify_via_email and notify_tradeya_news_updates)
    end
  end

  def get_user_total_tradeya_count
    return Item.count(:conditions => "status != 'DELETED' and tod = 1 and user_id = " + id.to_s)
  end

  def get_user_live_tradeya_count
    return Item.count(:conditions => "status = 'LIVE' and tod = 1 and user_id = " + id.to_s)
  end

  def get_user_total_offer_count
    return Trade.count(:conditions => "(status IS NULL or status != 'DELETED') and offer_id IN ( select id from items where user_id = " + id.to_s + ")")
  end

  def user_profile_status
    if goods_sub_cat_ids.size == 0
      return 0
    elsif services_sub_cat_ids.size == 0
      return 1
    elsif interests_sub_cat_ids.size == 0 or (wish.nil? or wish.size == 0)
      return 2
    else
      return 3
    end
  end

  def goods(to_s = true)
    cats = ((to_s) ? '' : [])
    if not self.goods_sub_cat_ids.blank?
      cat_ids = Category.find(:all, :conditions => ['id IN (' + self.goods_sub_cat_ids + ')'])
      if to_s
        cat_ids.each do |c|
          cats += ((cats.length == 0) ? c.name : ', ' + c.name)
        end
      else
        cats = cat_ids
      end
    end

    return cats
  end

  def services(to_s = true)
    cats = ((to_s) ? '' : [])

    if not services_sub_cat_ids.blank?
      cat_ids = Category.find(:all, :conditions => ['id IN (' + services_sub_cat_ids + ')'])
      if to_s
        cat_ids.each do |c|
          cats += ((cats.length == 0) ? c.name : ', ' + c.name)
        end
      else
        cats = cat_ids
      end
    end

    return cats
  end

  def interests(to_s = true, only_ids = false)
    cats = ((to_s) ? '' : [])

    if not interests_sub_cat_ids.blank?
      cat_ids = Category.find(:all, :conditions => ['id IN (' + interests_sub_cat_ids + ')'])
      if to_s
        cat_ids.each do |c|
          cats += ((cats.length == 0) ? c.name : ', ' + c.name)
        end
      elsif only_ids and not to_s
        cat_ids.each do |c|
          cats[cats.count] = c.id
        end
      else
        cats = cat_ids
      end
    end

    return cats
  end

  def matched_interests(u, only_ids = false)
    uis = self.interests(false, true)
    uis_1 = u.interests(false, true)
    matched_ids = ""
    uis.each do |uc|
      uis_1.each do |uc1|
        if uc == uc1
          matched_ids += ((matched_ids.length > 0) ? "," + uc.to_s : uc.to_s)
        end
      end
    end
    if matched_ids.length > 0
      if only_ids
        return JSON.parse("[" + matched_ids + "]")
      else
        return Category.find(:all, :conditions => ["id IN(#{matched_ids})", ])
      end
    else
      return []
    end
  end

  def matched_wants(u, only_ids = false)
    uis = self.user_wants
    uis_1 = u.user_wants
    matched_ids = ""
    uis.each do |uc|
      uis_1.each do |uc1|
        if uc.id == uc1.id
          matched_ids += ((matched_ids.length > 0) ? "," + uc.id.to_s : uc.id.to_s)
        end
      end
    end
    if matched_ids.length > 0
      if only_ids
        return JSON.parse("[" + matched_ids + "]")
      else
        return Category.find(:all, :conditions => ["id IN(#{matched_ids})"])
      end
    else
      return []
    end
  end

  def user_wants
    g = goods(false)
    s = services(false)
    return g.zip(s).flatten.compact
  end

  def tradeya_going2expire(other_person_tradeya = false, ignore_list = nil)
    return Item.tradeya_going2expire(self, other_person_tradeya, ignore_list)
  end

  def send_tradeya_match_mail(clear_prev = false)
    tradeya_match(clear_prev)
    tmr = TradeyaMatchingResult.match_result(self)
    if tmr.nil?
      return false
    else
      t = tmr.tradeya
      # add to user's matched items list
      self.tradeya_match_ids = ((self.tradeya_match_ids.nil? or self.tradeya_match_ids.blank?) ? "#{t.id}" : (self.tradeya_match_ids + ",#{t.id}"))
      self.save
      #################################
      tud = ThumbUpDown.new
      tud.user_id = self.id
      tud.item_id = t.id
      tud.person_id = t.user.id
      tud.match_type = CATEGORY_MATCH
      tud.token = SecureRandom.urlsafe_base64(25)
      tud.save

      EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_CATEGORY_MATCH, self.id, {:item_id => t.id, :vote_token => tud.token, :result_id => tmr.id })

      # return t
      return true
    end
  end

  def send_person_match_mail(clear_prev = false)
    pmr = PersonMatchingResult.match_result(self)
    if pmr.blank?
      return false
    else
      p = pmr.person
      tod = p.tradeya_going2expire(false,self.tradeya_match_ids)
      matched_interests = pmr.matched_interests(p)
      # add to user's matched persons, tradeya list
      self.person_match_ids = ((self.person_match_ids.nil? or self.person_match_ids.blank?) ? "#{p.id}" : (self.person_match_ids + ",#{p.id}"))
      self.tradeya_match_ids = ((self.tradeya_match_ids.nil? or self.tradeya_match_ids.blank?) ? "#{tod.id}" : (self.tradeya_match_ids + ",#{tod.id}"))
      self.save
      #################################
      tud = ThumbUpDown.new
      tud.user_id = self.id
      tud.item_id = tod.id
      tud.person_id = p.id
      tud.match_type = PERSON_MATCH
      tud.token = SecureRandom.urlsafe_base64(25)
      tud.save

      EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_PERSON_MATCH, self.id, {:person_id => p.id, :matched_interests => matched_interests.to_json, :vote_token => tud.token,:result_id => pmr.id, :item_id => tod.id})

      # return p
      return true
    end
    person_match(clear_prev)
  end

  def sort_test
    a = [[8,45,23,22],[4,2,55,7],[4,2,42,44],[8,44,33,10],[4,2,42,31]]
    puts a.to_s
    a = a.sort do |a,b|
      (a[0] <=> b[0]).nonzero? || (a[1] <=> b[1]).nonzero? || (a[2] <=> b[2]).nonzero? || (a[3] <=> b[3])
    end
    puts a.to_s
    puts a.to_json
  end

  def user_tradeyas_by_user_cats(u, only_ids = true, only_count = false)
    cats = []
    cats_in = ""

    gs = u.goods(false)
    gs.each do |g|
      cats[cats.count] = g.parent if cats.index(g.parent).nil?
    end
    ss = u.services(false)
    ss.each do |s|
      cats[cats.count] = s.parent if cats.index(s.parent).nil?
    end
    if cats.present?
      cats.each do |c|
        cats_in += ((cats_in.length > 0) ? "," + c.id.to_s : c.id.to_s)
      end
    end

    if cats_in.length == 0
      if only_count then return 0
      else return []
      end
    end

    query = Item.get_query_for_active_tradeyas
    if only_count
      return Item.count(:all, :conditions => [query + " AND category_id IN(#{cats_in}) AND user_id = ?", cats_in, self.id])
    elsif only_ids
      itms = Item.find(:all, :select => "id, title", :conditions => [query + " AND category_id IN(#{cats_in}) AND user_id = ?", self.id], :order => 'created_at DESC')
      ids = []
      itms.each do |i|
        ids[ids.count] = i.id
      end
      return ids
    else
      return Item.find(:all, :conditions => [query + " AND category_id IN(#{cats_in}) AND user_id = ?", self.id], :order => 'created_at DESC')
    end
  end

  def tradeya_match(clear_prev = false, limited_algo = false)
    if clear_prev
      # ActiveRecord::Base.connection.execute("UPDATE tradeya_matching_results SET status = " + MATCH_CLEAR.to_s + " WHERE user_id = " + self.id.to_s + " AND status = " + MATCH_PRESENT.to_s)
      self.clear_prev_tradeya_match
    end
    if ((goods_sub_cat_ids.size == 0 and services_sub_cat_ids.size == 0)  or TradeyaMatchingResult.isValidQ(self)) then return end


    cats = []
    cats_in = ""

    gs = goods(false)
    gs.each do |g|
      cats[cats.count] = g.parent if cats.index(g.parent).nil?
    end
    ss = services(false)
    ss.each do |s|
      cats[cats.count] = s.parent if cats.index(s.parent).nil?
    end
    if cats.present?
      cats.each do |c|
        cats_in += ((cats_in.length > 0) ? "," + c.id.to_s : c.id.to_s)
      end
    end

    query = Item.get_query_for_active_tradeyas
    # itms = Item.find(:all, :conditions => [query + " AND category_id IN(#{cats_in}) AND user_id != ?", self.id], :order => 'exp_date')
    matched_ids = self.tradeya_match_ids
    if limited_algo
      itms = Item.find(:all, :conditions => [query + " AND category_id IN(#{cats_in}) AND user_id != #{self.id}" + ((!matched_ids.nil? and matched_ids.length > 0) ? " AND id NOT IN (#{self.tradeya_match_ids})" : "")], :order => 'created_at DESC', :limit => 20)
    else
      itms = Item.find(:all, :conditions => [query + " AND category_id IN(#{cats_in}) AND user_id != #{self.id}" + ((!matched_ids.nil? and matched_ids.length > 0) ? " AND id NOT IN (#{self.tradeya_match_ids})" : "")], :order => 'created_at DESC')
    end
    items = []

    origin = nil
    if lat.present? and lng.present?
      origin = Geokit::LatLng.new(self.lat, self.lng)
    end

    itms.each do |i|
      if origin.present? and i.user.lat.present? and i.user.lng.present?
        idis = origin.distance_to([i.user.lat, i.user.lng])
        items[items.count] = [i, idis.round(1)]
      else
        items[items.count] = [i, 99999999999.0]
      end

      ints = self.matched_interests(i.user, true)
      wnts = self.matched_wants(i.user, true)
      if ints.count > 2 and wnts.count > 0
        items[items.count - 1][2] = TRADEYA_MATCH_TYPE_BEST
      elsif ints.count > 0
        items[items.count - 1][2] = TRADEYA_MATCH_TYPE_MINIMUM
      else
        items[items.count - 1][2] = TRADEYA_MATCH_TYPE_FINAL
      end

      items[items.count - 1][3] = ints
      items[items.count - 1][4] = wnts
    end

    items = items.sort do |a,b|
      (a[2] <=> b[2]).nonzero? || (a[1] <=> b[1]).nonzero? || (a[0].created_at <=> b[0].created_at)
    end

    if limited_algo
      if items.length > 0
        return items[0][0]
      else
        return nil
      end
    end

    count = 0
    ids = ""
    m_l_d = {}
    items.each do |a|
      count += 1
      if count > 5 then break end
      ids += ((ids.length > 0) ? "," + a[0].id.to_s : a[0].id.to_s)
      m_l_d[a[0].id] = [a[1], a[2], a[3], a[4]]
    end

    if ids.length > 0
      mr = TradeyaMatchingResult.new
      mr.user_id = self.id
      mr.match_result_q = ids
      mr.matched_log_data = m_l_d.to_json
      mr.save

      self.is_in_matching_q = false
      self.save
    else
      self.is_in_matching_q = true
      self.save
    end
  end

  def person_match(clear_prev = false)
    if clear_prev
      # ActiveRecord::Base.connection.execute("UPDATE person_matching_results SET status = " + MATCH_CLEAR.to_s + " WHERE user_id = " + self.id.to_s + " AND status = " + MATCH_PRESENT.to_s)
      self.clear_prev_person_match
    end
    if (interests_sub_cat_ids.size == 0 or PersonMatchingResult.isValidQ(self)) then return end


    cats = []
    mus = []
    u_int_match = {}
    origin = nil

    cats = interests(false, true)
    if lat.present? and lng.present?
      origin = Geokit::LatLng.new(self.lat, self.lng)
    end

    # usrs = User.find_by_sql("SELECT id, interests_sub_cat_ids, services_sub_cat_ids, goods_sub_cat_ids, lat, lng FROM users WHERE id != " + self.id.to_s + " AND active = 1")
    usrs = User.find_by_sql("SELECT id, interests_sub_cat_ids, services_sub_cat_ids, goods_sub_cat_ids, lat, lng FROM users WHERE active = 1 and id NOT IN ( #{self.id.to_s}" + ((!self.person_match_ids.nil? and self.person_match_ids.length > 0) ? ",#{self.person_match_ids}" : "") + ")")
    if usrs.present?
      usrs.each do |u|
        trds = u.user_tradeyas_by_user_cats(self)
        ints = self.matched_interests(u, true)
        wnts = self.matched_wants(u, true)
        if trds.count == 0 or ints.count == 0 then next end

        dis = -1
        if origin.present? and u.lat.present? and u.lng.present?
          dis = origin.distance_to([u.lat, u.lng])
          mus[mus.count] = [u, dis.round(1)]
        else
          mus[mus.count] = [u, 99999999999.0]
        end

        if ints.count > 2 and wnts.count > 2 and trds.count > 0
          mus[mus.count - 1][2] = TRADEYA_MATCH_TYPE_BEST
        elsif ints.count > 0
          mus[mus.count - 1][2] = TRADEYA_MATCH_TYPE_MINIMUM
        end

        mus[mus.count - 1][3] = ints
        mus[mus.count - 1][4] = wnts
        mus[mus.count - 1][5] = trds
      end
    end

    mus = mus.sort do |a,b|
      (a[2] <=> b[2]).nonzero? || (a[1] <=> b[1])
    end

    count = 0
    ids = ""
    m_l_d = {}
    mus.each do |a|
      count += 1
      if count > 5 then break end

      ids += ((ids.length > 0) ? "," + a[0].id.to_s : a[0].id.to_s)
      m_l_d[a[0].id] = [a[1], a[2], a[3], a[4], a[5]]
    end

    if ids.length > 0
      mr = PersonMatchingResult.new
      mr.user_id = self.id
      mr.match_result_q = ids
      mr.matched_log_data = m_l_d.to_json
      mr.save

      self.is_in_matching_q = false
      self.save
    else
      self.is_in_matching_q = true
      self.save
    end
  end

  #   def self.preview_item_match(sub_cat_ids, step,u)
  #     cat = []
  #     cat = sub_cat_ids.split(',')
  #     query = Item.get_query_for_active_tradeyas
  #     count = cat.length - 1
  #     for i in 0..count
  #     sub_cat = Category.get_category(cat[count-i])
  #     if sub_cat.nil? then next end
  #     itms = Item.find(:all, :conditions => [query + " AND category_id = #{sub_cat.category_id} AND user_id != #{u}" ], :order => 'created_at DESC')
  #     if itms.length > 0
  #       item = itms[0]
  #       if item.item_photos.length > 0
  #         return item.item_image(:medium)+"##img"
  #       elsif item.item_videos.length > 0
  #         return item.item_videos[0].video.to_s+"##video"
  #       end
  #     end
  #   end
  #   return self.preview_person_match(sub_cat_ids,step,u)
  # end

  def self.preview_person_match(sub_cat_ids,step,u)
    field = ''
    q = ''
    qry = ''
    if step == 1 then field = 'goods_sub_cat_ids'
    elsif step == 2 then field = 'services_sub_cat_ids'
    else field = 'interests_sub_cat_ids' end
    cat = sub_cat_ids.split(',')
    cat.each do |c|
      q = "select * from users where (" + field + " LIKE \'#{c},%\' OR " + field + " LIKE \'%,#{c},%\' OR " + field + " LIKE \'%,#{c}\') AND id != #{u}"
      if qry.length == 0 then qry = q
      else qry = "(#{qry}) UNION ALL (#{q})" end
    end
    if qry.length > 0
      full_query = "select tmp.id as id, count(*) as c from ( #{qry} ) as tmp group by tmp.id order by c desc"
      usrs = User.find_by_sql(full_query)
      if usrs.length > 0
        u = User.find(usrs[0].id)
        return u.user_image(:medium)+"##img"
      end
      return '/assets/default_Jared.jpeg##img'
    end
  end

  def clear_prev_tradeya_match
    ActiveRecord::Base.connection.execute("UPDATE tradeya_matching_results SET status = " + MATCH_CLEAR.to_s + " WHERE user_id = " + self.id.to_s + " AND status = " + MATCH_PRESENT.to_s)
  end

  def clear_prev_person_match
    ActiveRecord::Base.connection.execute("UPDATE person_matching_results SET status = " + MATCH_CLEAR.to_s + " WHERE user_id = " + self.id.to_s + " AND status = " + MATCH_PRESENT.to_s)
  end
  # def get_fb_friends
  #   if not fb_friends.nil?
  #     return JSON.parse(self.fb_friends)
  #   else
  #     return []
  #   end
  # end

  # def get_tw_friends
  #   if not tw_friends.nil?
  #     return JSON.parse(self.tw_friends)
  #   else
  #     return []
  #   end
  # end

  # def get_ln_friends
  #   if not ln_friends.nil?
  #     return JSON.parse(self.ln_friends)
  #   else
  #     return []
  #   end
  # end

  # def self.get_mutual_frnds(u1,u2)
  #   mutual_frnds = []

  #   begin
  #   # fb friends
  #   u1_fb = u1.get_fb_friends
  #   u2_fb = u2.get_fb_friends
  #   u1_fb.each do |f1|
  #     u2_fb.each do |f2|
  #       if f1["uid"] == f2["uid"]
  #         mutual_frnds.push(f1)
  #         break
  #       end
  #     end
  #   end
  #   # twitter friends
  #   u1_tw = u1.get_tw_friends
  #   u2_tw = u2.get_tw_friends
  #   u1_tw.each do |f1|
  #     u2_tw.each do |f2|
  #       if f1["uid"] == f2["uid"]
  #         mutual_frnds.push(f1)
  #         break
  #       end
  #     end
  #   end

  #   # linked friends
  #   u1_ln = u1.get_ln_friends
  #   u2_ln = u2.get_ln_friends
  #   u1_ln.each do |f1|
  #     u2_ln.each do |f2|
  #       if f1["uid"] == f2["uid"]
  #         mutual_frnds.push(f1)
  #         break
  #       end
  #     end
  #   end
  # rescue
  #   mutual_frnds = []
  # end
  #   return mutual_frnds
  # end

  # def update_fb_friends
  #   fb_frnds = []
  #   uids = ""
  #   begin
  #   a1 = self.authentication('facebook')
  #   if not a1.nil?
  #     u1_fs = HTTParty.get('https://graph.facebook.com/' + a1.uid + '/friends?access_token=' + a1.access_token + '&limit=5000')
  #     d1 = JSON.parse(u1_fs.body)["data"]
  #     d1.each do |f1|
  #       arr = Hash.new
  #       arr["image"] = User.user_image_by_uid(f1["id"])
  #       arr["name"] = f1["name"]
  #       arr["uid"] = f1["id"]
  #       fb_frnds.push(arr)
  #       uids = uids + (uids.length == 0 ? "" : ",") + "'" + f1["id"] + "'"
  #     end
  #   end
  #   if fb_frnds.length > 0 then fb_frnds = update_fb_friends_locations(fb_frnds,uids) end
  #   rescue
  #     fb_frnds = []
  #   end
  #   self.fb_friends = fb_frnds.to_json
  #   self.save
  # end

  def update_fb_friends_locations(fb_frnds,uids)
    a = self.authentication('facebook')
    begin
      addrs = []
      if uids.length > 0
        q = 'SELECT uid, current_location FROM user WHERE uid IN(' + uids + ')'
        q = URI.encode(q)
        addrs = HTTParty.get('https://graph.facebook.com/fql?q=' + q + '&access_token=' + a.access_token + '&limit=5000')
      end
      addrs = JSON.parse(addrs.body)["data"]

      fb_frnds.each do |h|
        addrs.each do |addr|
          if addr["uid"].to_s == h["uid"].to_s
            cl = addr["current_location"]
            if not cl.nil?
              h["location"] = (cl["city"].blank? ? "" : cl["city"].gsub(", ", " ").gsub(",", " ")) + (cl["state"].blank? ? "" : (cl["city"].blank? ? cl["state"] : " " + cl["state"])) + (cl["zip"].blank? ? "" : ((cl["city"].blank? and cl["state"].blank?) ? cl["zip"] : " " + cl["zip"]))
              if h["location"].length == 0 then h[:location] = cl["name"] end
            end
            break
          end
        end

        if h["location"].nil? or h["location"].length == 0
          usr = User.user_by_uid(h["uid"])
          if usr
            h["location"] = usr.location
          end
        end
      end
    rescue
    end

    return fb_frnds
  end

  # def update_tw_friends
  #   tw_frnds = []

  #   begin
  #     a1 = self.authentication('twitter')
  #     mt_ids = ""
  #     if not a1.nil?
  #       u1_fs = HTTParty.get('https://api.twitter.com/1/friends/ids.json?user_id=' + a1.uid.to_s)
  #       d1 = JSON.parse(u1_fs.body)["ids"]
  #       d1.each do |f|
  #           mt_ids = mt_ids.blank? ? "#{d1[d1.index(f)]}" : "#{mt_ids},#{d1[d1.index(f)]}"
  #         end
  #       if !mt_ids.blank?
  #         details = HTTParty.get('https://api.twitter.com/1/users/lookup.json?user_id=' + mt_ids)
  #         friends = JSON.parse(details.body)
  #         friends.each do |f|
  #           arr = Hash.new
  #           arr["image"] = f["profile_image_url"]
  #           arr["name"] = f["name"]
  #           arr["uid"] = f["id_str"]
  #           arr["location"] = f["location"]
  #           tw_frnds.push(arr)
  #         end
  #       end
  #     end

  #   rescue
  #     tw_frnds = []
  #   end

  #   self.tw_friends = tw_frnds.to_json
  #   self.save
  # end

  # def update_ln_friends
  #   ln_frnds = []
  #   begin
  #     a1 = self.authentication('linkedin')

  #     if not a1.nil?
  #       client = LinkedIn::Client.new(LINKEDIN_CONSUMER_KEY, LINKEDIN_CONSUMER_SECRET, LINKEDIN_CONFIGURATION)
  #       client.authorize_from_access(a1.access_token, a1.access_secret)
  #       cons1 = client.connections
  #       cons1.all.each do |c1|
  #         if c1.id != 'private'
  #           arr = Hash.new
  #           arr["image"] = (c1.picture_url.nil? ? "https://s3.amazonaws.com/tradeya_prod/tradeya/images/TY_DefaultUser_sm.gif" : c1.picture_url)
  #           arr["name"] = c1.first_name + ((c1.last_name.nil? or c1.last_name.length == 0) ? "" : " ") + c1.last_name
  #           arr["uid"] = c1.id
  #           arr["location"] = (c1.location.nil? ? "" : c1.location.name)
  #           ln_frnds.push(arr)
  #         end
  #       end
  #     end
  #     rescue
  #       ln_frnds = []
  #     end

  #   self.ln_friends = ln_frnds.to_json
  #   self.save
  # end

  # def self.update_friend_list(uid,type=nil)
  #   u = User.find_by_id(uid)
  #   if not u.nil?
  #     if type.nil?
  #       u.update_fb_friends
  #       u.update_tw_friends
  #       u.update_ln_friends
  #     elsif type == 'facebook'
  #       u.update_fb_friends
  #     elsif type == 'twitter'
  #       u.update_tw_friends
  #     elsif type == 'linkedin'
  #       u.update_ln_friends
  #     end
  #   end
  # end

  def mark_all_alert_read
    Alert.mark_read(self)
  end

  def guest_days_left
    return (((self.created_at + 30.days) - Time.zone.now)/(24*60*60)).ceil
  end

  def has_liked?(item_id)
    return self.likes.where(:item_id => item_id).present?
  end

  def has_item?(item_id)
    return self.haves.where(:item_id => item_id).present?
  end

  def wants_item?(item_id)
    return self.wants.where(:item_id => item_id).present?
  end

  def distance_between_users(current_user_location,user)
    return Geocoder::Calculations.distance_between(current_user_location,
                                                   [user.lat,user.lng]).round(2) unless current_user_location.blank?
  end

  def coordinates
    return [lat.to_f,lng.to_f]
  end

  def user_distance(coordinates)
    begin
      if coordinates.count < 2
        return nil
      else
        return Geocoder::Calculations.distance_between(coordinates,[lat,lng]).round(2) unless lat.blank? or lng.blank?
      end
    rescue
      return nil
    end
  end

  def wanted_items
    # return self.wants.includes({item: :user}).order("created_at DESC")
    return Want.joins(:user,:item).where('users.id'=>"#{self.id}",'items.status'=>'LIVE')
  end

  def owned_wanted_items
    # User's items wanted by others
    Want.joins(:item).where('items.user_id' => "#{self.id}", 'items.status'=>'LIVE').order("wants.created_at DESC")
  end

  # TODO - change this method
  def have_items
    return self.items.live.order("created_at DESC")
  end

  def liked_items
    # return self.likes.includes({item: :user}).order("created_at DESC")
    return Like.joins(:user,:item).where('users.id'=>"#{self.id}",'items.status'=>'LIVE').order("likes.created_at DESC")
  end

  def followed_items
    return self.follows.order("created_at DESC")
  end

  #TODO need refactoring
  def past_trades
    return Trade.joins("left outer join items on items.id = trades.item_id left outer join items as offers on offers.id = trades.offer_id")
    .where("items.user_id = #{self.id} or offers.user_id = #{self.id}")
    .traded.select("trades.*, items.user_id as item_user_id, offers.user_id as offer_user_id").order_by_latest

  end

  def unreview_trades
    t = Trade.joins("left join items on items.id = trades.item_id left join items as offer on offer.id = trades.offer_id").where("items.user_id = #{self.id} or offer.user_id = #{self.id}").traded.pluck("trades.id")
    # AcceptedOffer.where("trade_id IN (?) and id not in(select accepted_offer_id from reviews where reviews.reviewer_id = #{self.id})",t)
    AcceptedOffer.joins(trade: [:item,:offer])
    .where("trade_id IN (?) and accepted_offers.id not in(select accepted_offer_id from reviews where reviews.reviewer_id = #{self.id})",t).order("created_at DESC")
    .select("accepted_offers.*,items.user_id as item_user_id,items.id as item_id,offers_trades.user_id as offer_user_id,offers_trades.id as offer_id")
  end

  def user_reviews
    return self.reviews_written
    # return Review.where(:reviewer_id => self.id)
  end

  def untraded_items
    return Trade.joins("left outer join items on items.id = trades.item_id left outer join items as offers on offers.id = trades.offer_id")
    .where("items.user_id = #{self.id} or offers.user_id = #{self.id}")
    .where("trades.id not in (select trade_id from accepted_offers)")
  end

  def describe_rating
    if self.reviews.present?
      rating = 0
      arr = self.reviews
      arr.each do |r|
        rating = rating + r.describe_rating.to_f
      end
      return rating/arr.size
    else
      return nil
    end
  end

  def communication_rating
    if self.reviews.present?
      rating = 0
      arr = self.reviews
      arr.each do |r|
        rating = rating + r.communication_rating.to_f
      end
      return rating/arr.size
    else
      return nil
    end
  end

  def overall_rating
    if self.reviews.present?
      rating = 0
      arr = self.reviews
      self.reviews.each do |r|
        rating = rating + r.overall_rating.to_f
      end
      return rating/arr.size
    else
      return nil
    end
  end

  def get_review_buckets(column)
    if self.reviews.present?
      ratings = Hash.new()
      ratings[5] = self.reviews.where("overall_rating >= 5").pluck(column).size
      ratings[4] = self.reviews.where("overall_rating < 5 and overall_rating >= 4").pluck(column).size
      ratings[3] = self.reviews.where("overall_rating < 4 and overall_rating >= 3").pluck(column).size
      ratings[2] = self.reviews.where("overall_rating < 3 and overall_rating >= 2").pluck(column).size
      ratings[1] = self.reviews.where("overall_rating < 2 and overall_rating >= 1").pluck(column).size
      ratings[0] = self.reviews.where("overall_rating < 1 and overall_rating >= 0").pluck(column).size
      return ratings
    end
  end

  #-----------------------------------------------------------------------------#
  # my_offers_grouped_by_item ----> "user's offers grouped by items/tradeya"
  # Params --- IN:
  # Params --- OUT:
  # +trades_by_items+:: Hash object with key as item ID and value as array of trades on it
  #------------------------------------------------------------------------------#
  def my_offers_grouped_by_item
    trd_ids = self.reverse_trades.where(:items => {:status => 'LIVE'}).with_live_item.pluck(:id)
    if trd_ids.blank? then return nil end
    trades_by_items = {}
    trades = Trade.where(:id => trd_ids).order_by_latest.includes(:item,:offer)
    trades.each do |tr|
      if trades_by_items.has_key?(tr.item_id)
        arr = trades_by_items[tr.item_id]
      else
        arr = Array.new
      end
      arr[arr.length] = tr
      trades_by_items[tr.item_id] = arr
    end
    return trades_by_items
  end

  def has_request_info?(item_id)
    return self.request_info_items.where(:item_id => item_id).present?
  end

  def facebook_friends
    return self.facebook_graph.get_connections("me", "friends")
  end

  def fb_friends_authentications(fb_uids)
    Authentication.where(:provider => 'Facebook').where('uid IN (?)', fb_uids).order("created_at DESC")
  end

  def twitter_friends
    twitter_client = Twitter::Client.new(
                                         :oauth_token => self.authentications.where(:provider => 'twitter').first.access_token,
                                         :oauth_token_secret => self.authentications.where(:provider => 'twitter').first.access_secret
                                        )
    twitter_client.friend_ids.collection
  end

  def tw_friends_authentications(tw_uids)
    Authentication.where(:provider => 'Twitter').where('uid IN (?)', tw_uids).order("created_at DESC")
  end

  def friends_not_on_tradeya
    # facebook friends
    if self.facebook_authenticated?
      begin
        fb_friends = self.facebook_friends
        fb_uids = fb_friends.collect{ |f| f["id"] }
        fb_friends_on_tradeya = self.fb_friends_authentications(fb_uids).collect{ |f| f["uid"] }
        fb_friends_not_on_tradeya = fb_uids - fb_friends_on_tradeya
        fb_friends_not_on_tradeya = fb_friends_not_on_tradeya.sample(3)

        friends_not_on_tradeya = []

        fb_friends_not_on_tradeya.each do |fb_user|
          name = self.facebook_graph.get_object(fb_user) {|u| u['name']}
          picture = self.facebook_graph.get_picture(fb_user)
          friends_not_on_tradeya.push([name, picture, fb_user])
        end
      rescue
        friends_not_on_tradeya = nil        
      end

      return friends_not_on_tradeya
    end
  end

  def friends_on_tradeya
    User.joins("INNER JOIN follows on follower_id = #{self.id} and users.id = follows.followed_id").order("RAND()").take(3)

  end

  def common_friends(user)
    my_follows = Follow.where(:follower_id => self.id).pluck(:followed_id)
    his_follows = Follow.where(:follower_id => user.id).pluck(:followed_id)
    common_friends = my_follows & his_follows
    return User.find_all_by_id(common_friends, :include => [:user_photos])
  end

  def alert_activities
    Want
  end

  def activity_feed(sort_by)
    PublicActivity::Activity.where("deleted = false and private = 0 and owner_id IN (?)", self.followed_users.pluck(:id)).order("created_at DESC").includes(:trackable).includes(:owner).reject{|activity| !activity.trackable.present?}.first(5)
    
    # if sort_by == "type"
    #   PublicActivity::Activity.where("deleted = false and (owner_id = " + self.id.to_s + " or recipient_id = " + self.id.to_s + ")").order("trackable_type ASC","created_at DESC").includes(:owner).reject{|activity| !activity.trackable.present?}
    # else

    # PublicActivity::Activity.where("deleted = false and (owner_id = " + self.id.to_s + " or recipient_id = " + self.id.to_s + ")").order("created_at DESC").includes(:trackable).includes(:owner).reject{|activity| !activity.trackable.present?}
    # end
  end

  def unviewed_activity_count
    PublicActivity::Activity.where("deleted = false and viewed_by_owner = true and (owner_id = " + self.id.to_s + ")").reject{|activity| !activity.trackable.present?}.count
  end

  def verified_phone_number
    return PhoneNumber.find(:all, :conditions => {:user_id => self.id, :verified => true}).last
  end

  def unverified_phone_number
    return PhoneNumber.find(:all, :conditions => {:user_id => self.id, :verified => false}).last
  end

  # returns items owned by user's friends (whom he follows) sorted by date created
  def friends_items
    Item.joins("left outer join follows on follows.followed_id = items.user_id").where("follows.follower_id = #{self.id}").live.pluck(:id)#order("created_at DESC")
  end

  def following_users
    User.joins("INNER JOIN follows on follows.followed_id = users.id").where("follows.follower_id=#{self.id}").order("follows.created_at DESC")
  end

  def followed_by_users
    User.joins("INNER JOIN follows on follows.follower_id = users.id").where("follows.followed_id=#{self.id}").order("follows.created_at DESC")
  end

  def self.autocomplete_for(query)
    if query.present?
      @users = User.where("first_name LIKE ? OR last_name LIKE ?", "%#{query}%", "%#{query}%").select([:first_name, :last_name, :email]).limit(10).map { |e| { name: "#{e.first_name} #{e.last_name}", id: e.email } }
    else
      @users = []
    end
  end

  def self.index_users_redis
    User.find_each do | user |
      index_user(user)
    end
  end

  def self.index_user(user)

  end

  def save_tracking_info(session)
    tracking_info = TrackingInfo.find_or_create_by_user_id(self.id)
    tracking_info[:sbx_code] = session[:sbx_code] if session[:sbx_code].present?
    tracking_info[:utm_campaign] = session[:utm_campaign] if session[:utm_campaign].present?
    tracking_info[:utm_source] = session[:utm_source] if session[:utm_source].present?
    tracking_info[:utm_medium] = session[:utm_medium] if session[:utm_medium].present?
    tracking_info[:utm_content] = session[:utm_content] if session[:utm_content].present?
    tracking_info[:sbx_term] = session[:sbx_term] if session[:sbx_term].present?
    tracking_info.save
  end

  def utm_params
    utm_hash =   {
                  utm_campaign: self.tracking_info.utm_campaign, 
                  utm_source: self.tracking_info.utm_source, 
                  utm_medium: self.tracking_info.utm_medium, 
                  utm_content: self.tracking_info.utm_content, 
                  utm_term: self.tracking_info.utm_term
                 }
    return utm_hash
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

end
