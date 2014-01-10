desc "Setup initial db."
namespace :db do
# rake to populate categories table with new categories
  task :setup_new_categories => [:environment] do

# Delete all categories
    Category.where("id >= 1000").delete_all

# LEVEL 0 have 1 category that is root
    begin
      Category.new(:id => 1000, :name => 'new_root').save
    rescue StandardError => e
      puts "Already exists root!"
    end

    arr_o_arr = []

# LEVEL 1 have 3 category
    arr_o_arr[arr_o_arr.count] = "1001:Goods:1000,1002:Services:1000,1003:Housing:1000".split(',')

# LEVEL 2
  # GOODS
    arr_o_arr[arr_o_arr.count] = "2001:Antiques:1001;2002:Appliances:1001;2003:Art:1001;2004:Arts / Crafts:1001;2005:Auto Parts:1001".split(';')
    arr_o_arr[arr_o_arr.count] = "2006:Baby / Kids:1001;2007:Beauty / Health:1001;2008:Bikes:1001;2009:Boats:1001;2010:Books:1001".split(';')
    arr_o_arr[arr_o_arr.count] = "2011:Business:1001;2012:Cars / Trucks:1001;2013:CDs / DVDs / VHS:1001;2014:Cell Phones:1001;2015:Clothes / Accessories:1001".split(';')
    arr_o_arr[arr_o_arr.count] = "2016:Club Memberships:1001;2017:Collectibles:1001;2018:Computer:1001;2019:Electronics:1001;2020:Farm / Garden:1001".split(';')
    arr_o_arr[arr_o_arr.count] = "2021:Food / Drink:1001;2022:Furniture:1001;2023:General:1001;2024:Gift Cards / Coupons:1001;2025:Household:1001".split(';')
    arr_o_arr[arr_o_arr.count] = "2026:Jewellery:1001;2027:Materials:1001;2028:Memorabilia:1001;2029:Motorcycles:1001;2030:Musical Instruments:1001".split(';')
    arr_o_arr[arr_o_arr.count] = "2031:Others:1001;2032:Photo / Video:1001;2033:Real Estate:1001;2034:RVs:1001;2035:Sporting:1001".split(';')
    arr_o_arr[arr_o_arr.count] = "2036:Tickets:1001;2037:Tools:1001;2038:Toys / Games:1001;2039:Video Games:1001".split(';')
  # SERVICES
    arr_o_arr[arr_o_arr.count] = "3001:Accounting / Finance:1002;3002:Admin / Office:1002;3003:Arch / Engineering:1002;3004:Art / Media / Design:1002;3005:Automotive:1002".split(';')
    arr_o_arr[arr_o_arr.count] = "3006:Beauty:1002;3007:Biotech / Science:1002;3008:Business / Mgmt:1002;3009:Child Care:1002;3010:Craft:1002".split(';')
    arr_o_arr[arr_o_arr.count] = "3011:Customer Service:1002;3012:Cycle:1002;3013:Education / Tutoring:1002;3014:Event / Entertaining:1002;3015:Farm / Garden:1002".split(';')
    arr_o_arr[arr_o_arr.count] = "3016:Food / Bev / Hosp:1002;3017:General Labor:1002;3018:Home:1002;3019:Human Resources:1002;3020:Internet Engineers:1002".split(';')
    arr_o_arr[arr_o_arr.count] = "3021:Legal / Paralegal:1002;3022:Lessons / Tutoring:1002;3023:Manufacturing:1002;3024:Marine:1002;3025:Marketing / PR / Ad:1002".split(';')
    arr_o_arr[arr_o_arr.count] = "3026:Medical / Dental / Health:1002;3027:Moving:1002;3028:Organization / Personal:1002;3029:Others:1002;3030:Pet:1002".split(';')
    arr_o_arr[arr_o_arr.count] = "3031:Real Estate:1002;3032:Recreational Services:1002;3033:Sales / Biz Dev:1002;3034:Salon / Spa / Fitness:1002;3035:Skilled Trade:1002".split(';')
    arr_o_arr[arr_o_arr.count] = "3036:Software / QA / DBA:1002;3037:Systems / Network:1002;3038:Technical Support:1002;3039:Therapeutic:1002;3040:Transport:1002".split(';')
    arr_o_arr[arr_o_arr.count] = "3041:Travel / Vacation:1002;3042:TV / Film / Video:1002;3043:Web / Info Design:1002;3044:Writing / Editing:1002".split(';')
  # HOUSING
    arr_o_arr[arr_o_arr.count] = "4001:Long-term:1003;4002:Permanent Swap:1003;4003:Short-term:1003".split(';')

    arr_o_arr.each do |arr|
      arr.each do |c|
        r = c.split(':')
        begin
          cat = Category.new(:id => r[0].to_i, :name => r[1], :category_id => r[2].to_i)
          cat.save
        rescue StandardError => e
          puts e.message
          puts "Already exists: " + c
        end
      end
    end

    system("curl 'http://#{DOMAIN}/clear_category_cache'")
  end
end