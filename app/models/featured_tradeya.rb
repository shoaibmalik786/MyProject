class FeaturedTradeya < ActiveRecord::Base
	belongs_to :item, :conditions => "tod = 1"

	attr_accessible :startDate, :endDate, :item_id

## validations
	validates :item_id, :presence => {:message => "Select a tradeya item"}
	validates :startDate, :presence=> {:message => "Startdate cannot be blank"}
	validates :endDate, :presence => {:message => "Enddate cannot be blank"}
	validate :checkDates, :if => "startDate != nil && endDate != nil" 
 

def self.current_featured_list
	return FeaturedTradeya.find(:all, :conditions => self.current_featured_list_condition, :order => "startDate")
end

def self.make_featured_tradeyas(how_many, ft_ids, ft_uids)
  tods = Item.tradeyas_canbe_featured
  tod_cat_a = []
  tod_a = []
  # Do not repeat TradeYas by users and categories
  tods.each do |tod|
    if tod_cat_a.index(tod.category_id).nil? and ft_ids.index(tod.id).nil? and ft_uids.index(tod.user_id).nil?
      tod_cat_a[tod_cat_a.count] = tod.category_id
      ft_uids[ft_uids.count] = tod.user_id
      tod_a[tod_a.count] = tod
    end
    if tod_cat_a.count >= how_many then break end
  end
  # Do not repeat TradeYas by users
  if tod_a.count < how_many
    tods.each do |tod|
      if tod_a.index(tod).nil? and ft_ids.index(tod.id).nil? and ft_uids.index(tod.user_id).nil?
        ft_uids[ft_uids.count] = tod.user_id
        tod_a[tod_a.count] = tod
      end
      if tod_a.count >= how_many then break end
    end
  end
  if tod_a.count < how_many
    tods.each do |tod|
      if tod_a.index(tod).nil? and ft_ids.index(tod.id).nil?
        tod_a[tod_a.count] = tod
      end
      if tod_a.count >= how_many then break end
    end
  end
  # TODO - change enddate
  tod_a.each do |tod|
    FeaturedTradeya.create(:startDate => Time.zone.now, :endDate => tod.exp_date, :item_id => tod.id)
  end
  return tod_a
end

  def self.current_featured_list_condition
    now = Time.now.to_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
    return "(startDate <= '#{now}' AND endDate >= '#{now}')"
  end

# def self.completed_featured_list
#   item_ids = ""
#   temp = self.find_by_sql("select item_id from featured_tradeyas where endDate <= NOW()")
#   temp.each do |x|
#     item_ids = item_ids.blank? ? "#{x.item_id}" : "#{item_ids},#{x.item_id}"
#   end
#   return item_ids
# end

# Update Featured List in Info And Settings Table
  def self.update_featured_list
    featured_tods = Item.featured_tradeyas(5,true,nil)
    item_ids_str = ''
    featured_tods.each do |tod|
      item_ids_str += ((item_ids_str.length > 0) ? ',' + tod.id.to_s : tod.id.to_s )
    end
    # set this item_id_str in a column in InfoAndSettings
    InfoAndSetting.featured_tradeyas(item_ids_str)
  end
private
## Custome validation menthod - to check startDate and endDate
  def checkDates
  	errors.add(:endDate, "Enddate should be greater than Startdate") unless endDate > startDate
  end
end
