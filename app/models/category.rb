class Category < ActiveRecord::Base
  has_many :items
  has_many :item_wants
  has_many :categories
  belongs_to :parent, :class_name => "Category", :foreign_key => "category_id"
  scope :roots, :conditions => ["id = 1000"]
  scope :goods, :conditions => ["category_id = 1001"]
  scope :services, :conditions => ["category_id = 1002"]
  scope :housing, :conditions => ["category_id = 1003"]

  validates :name, :uniqueness => {:scope => :category_id}
  attr_accessible :id, :name, :category_id

  def self.root
    if roots.length > 0
      return roots[0]
    else
      c = Category.new
      c.name = 'root'
    end
  end

  def title
    if(parent)
      return ('<b>' + parent.name.upcase + '</b>' + ': ' + name).html_safe
    else
      return name
    end
  end
  
  def self.get_category(id)
    if Item.isNumber(id)
      return self.find(:first, :conditions => {:id => id })
    else
      return nil
    end
  end

  def self.child_categories(id)
    tmp = self.find(:all, :conditions => {:category_id => id })
    tmp.each do |c|
      c.name = c.name.initcaps
    end
    return tmp
  end

  def self.goods_sub_categories
    get_sub_categories_for_creating_profile(2)
  end

  def self.services_sub_categories
    get_sub_categories_for_creating_profile(3)
  end

  def self.interests_sub_categories
    return get_sub_categories_for_creating_profile(385)
  end

  def self.get_sub_categories_for_creating_profile(id)
    sub_cat = Array.new
    categories = child_categories(id)
    categories.each do |cat|
      if cat.imageURL
        cat_info = Hash.new
        cat_info["id"] = cat.id
        cat_info["name"] = cat.name.initcaps
        cat_info["imageURL"] = cat.imageURL
        cat_info["sub"] = child_categories(cat.id)
        sub_cat.push(cat_info) unless cat_info["sub"].size < 1
      end
    end
    return sub_cat
  end

  def general_misc_cat
    return self.categories.first(:conditions => ["name = 'general + misc'"]) unless self.categories.nil?
  end
  
end
