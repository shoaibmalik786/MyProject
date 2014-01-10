# They can be executed as follows:

desc "Setup initial db."
namespace :db do
# rake setup categories to db.
  task :setup_categories => [:environment] do

# Delete all categories
    Category.delete_all

# LEVEL 0 have 1 category that is root
    begin
      Category.new(:id => 1, :name => 'root').save
    rescue StandardError => e
      puts "Already exists root!"
    end

    arr_o_arr = []
# LEVEL 1 have 3 category
    arr_o_arr[arr_o_arr.count] = "2:Goods:1,3:Services:1,385:Interests:1".split(',')

# LEVEL 2
  # GOODS
    arr_o_arr[arr_o_arr.count] = "4:Arts & Collectibles:2:/assets/category_1.png;5:Clothing / Jewelry / Accessories:2:/assets/category_3.png;6:Electronics:2:/assets/category_4.png;7:Furniture / Antiques / Appliances:2:/assets/category_2.png;8:Others:2;9:Housing & Vacation Spots:2:/assets/category_6.png;10:Media + Entertainment:2:/assets/category_7.png;11:Office / Photos / Music gear:2:/assets/category_8.png;13:Tickets & Coupons:2:/assets/category_9.png;14:Vehicles & Parts:2:/assets/category_10.png;479:Handmade:2".split(';')
  # SERVICES
    arr_o_arr[arr_o_arr.count] = "15:Accounting / Finance / Legal:3:/assets/step2_cat1.png;16:Architecture + Engineering:3:/assets/step2_cat2.png;17:Art / Media / Web Design:3:/assets/step2_cat3.png;18:Beauty / Fitness / Health:3:/assets/step2_cat4.png;19:Business / Consulting / Office:3:/assets/step2_cat5.png;20:Coaches / Healers / Therapists:3:/assets/step2_cat6.png;22:Education & Tutoring:3:/assets/step2_cat7.png;23:Food & nutrition:3:/assets/step2_cat8.png;24:Others:3;25:Programmers & Developers:3:/assets/step2_cat9.png;26:Vehicle Repair & Maintenance:3:/assets/step2_cat10.png".split(';')
  # INTERESTS
    arr_o_arr[arr_o_arr.count] = "386:Sports You Play or Teach:385:/assets/step3_cat1.png;387:Hobbies You're Into:385:/assets/step3_cat2.png;388:You Going Out:385:/assets/step3_cat3.png".split(';')
    
# LEVEL 3
  ## GOODS
  # antiques + furniture
    arr_o_arr[arr_o_arr.count] = "27:Contemporary + Modern Art:4;28:Postmodern / Street Art:4;29:Photography + Fine Art:4;30:Renaissance / Classics:4;31:Computer / Digital Art:4;32:Installation Art:4;33:DIY Art:4;34:Super Old School Comics (1897-1969):4;35:Old School Comics (1970-1991):4;36:New School Comics (1984-1991) :4;37:Coins + Paper Money:4;38:Dolls + Bears:4;39:Entertainment Memorabilia:4;40:Sports Cards + Memorabilia:4;41:Stamp Collecting:4;42:Antique Accents:4;43:Antique Furniture:4".split(';')
  # sporting goods - 12
    arr_o_arr[arr_o_arr.count] = "198:Boats + Accessories:12;199:Camp + Hike:12;200:Climbing Gear:12;201:Fishing Gear:12;202:Home Fitness Equipment:12;203:Hunting Equipment:12;204:Mountain Bikes + Accessories:12;205:Paintball Guns + Accessories:12;206:Road Bikes + Accessories:12;207:Snorkeling + Scuba Gear:12;208:Snowmobile + Accessories:12;209:Towable Tubes/Skies:12;210:Wetsuits + Life Vests:12;211:Archery Gear:12;212:Airsoft Guns + Accessories:12;213:ATVs + Accessories:12;214:BMX Bikes + Accessories:12;215:Motorcross Bikes + Accessories:12;216:Skateboards/Longboards + Accessories:12;217:Skiing:12;218:Snowboarding:12;219:Surfboards + Bodyboards:12;220:Water Skis & Wakeboards:12;221:Water Sport Accessories:12;222:Baseball Equipment:12;223:Basketball Equipment:12;224:Football Equipment:12;225:Ice Hockey Equipment:12;226:Lacrosse Equipment:12;227:Soccer Equipment:12;228:Sports Medicine:12;229:Volleyball Equipment:12;230:Sports Training Equipment:12".split(';')
  # clothing + jewelry - 5
    arr_o_arr[arr_o_arr.count] = "44:Men's Classic/ Traditional Clothing:5;45:Men's Preppy Clothing:5;46:Men's Bohemian/ Hippie Clothing:5;47:Men's Rock/Funk Style Clothing:5;48:Men's Skater/ Alternative Clothing:5;49:Men's Goth Clothing:5;50:Men's Streetwear:5;51:Men's Shoes:5;52:Men's Bags:5;53:Men's Belts:5;54:Men's Ties:5;55:Men's Hats, Scarves + Gloves:5;56:Men's Cuff Links + Collar Stays:5;57:Men's Leather Goods:5;58:Men's Sunglasses:5;59:Women's Classic/ Traditional Clothing:5;60:Women's Preppy Clothing:5;61:Women's Bohemian/ Hippie Clothing:5;62:Women's Rock/ Funk Style Clothing:5;63:Women's Skater/ Alternative Clothing:5;64:Women's Goth Clothing:5;65:Women's Streetwear:5;66:Women's Shoes:5;67:Women's Handbags:5;68:Women's Sunglasses:5;69:Women's Accessories:5;70:Children's Clothing:5;71:Children's Shoes + Accessories:5;72:Contemporary Jewelry:5;73:Fine Jewelry:5;74:Vintage Jewelry:5;75:Bracelets & Bangles:5;76:Earrings:5;77:Necklaces:5;78:Pins & Brooches:5;79:Rings:5;80:Men's Watches:5;81:Women's Watches:5".split(';')
  # electronics + devices - 6
    arr_o_arr[arr_o_arr.count] = "82:Cameras + Photography:6;83:Cell Phones + Accessories:6;84:Computers + Tablets:6;85:TV, Audio + Surveillance:6;86:Video Games + Consoles:6".split(';')
  # general + misc - 7
    ########################
  # household + garden - 8
    arr_o_arr[arr_o_arr.count] = "87:Arts + Crafts:8;88:Baby Goods:8;89:Apt/Dorm Home Appliances:8;90:Family Home Appliances:8;91:Gardening Tools:8;92:Patio Furniture + Decor:8;93:Cat Supplies:8;94:Dog Supplies:8;95:Fish Supplies:8;96:Small Animal Supplies:8;97:Action Figures & Collectibles:8;98:Arts & Crafts for Kids:8;99:Baby Toys:8;100:Books, Movies & Music for Kids:8;101:Building Sets & Blocks:8;102:Dolls & Stuffed Animals:8;103:Electronics for Kids:8;104:Games & Puzzles:88;105:Kids' Room:8;106:Learning Toys:8;107:Music Instruments for Kids:8;108:Outdoor Play Toys:8;109:Party Supplies:8;110:Preschool Toys:8;111:Pretend Play & Dress Up:8;112:Science & Discovery for Kids:8;113:Specialty Toys:8;114:Vehicles & Radio Control Toys:8;115:Bohemian Furniture:8;116:Contemporary Furniture:8;117:Eclectic Furniture:8;118:English Country Furniture:8;119:Mid-Century Modern Furniture:8;120:Traditional Furniture:8;121:Vintage Furniture:8".split(';')
  # housing + vacation spots - 9
    arr_o_arr[arr_o_arr.count] = "122:Apartment Hosting:9;123:Chic City Loft Hosting:9;124:Condo Hosting:9;125:Farm/ Ranch Hosting:9;126:Family House Hosting:9;127:Mobile Home/Houseboat Hosting:9;128:Residential for Trade:9;129:Land for Trade:9;130:Multifamily or Commercial for Trade:9;131:Businesses for Trade:9;132:Vacation Rentals + Timeshares:9;133:Mobile Home/Houseboat for Trade:9;134:Townhome Hosting:9;135:Adventure Vacations:9;136:Luxury Vacations:9;137:Mountain Vacations:9;138:Park Vacations:9;139:Romantic Vacations:9".split(';')
  # media + entertainment - 10
    arr_o_arr[arr_o_arr.count] = "140:Action + Adventure Movies:10;141:Anime Movies:10;142:Children + Family Movies:10;143:Classic Movies:10;144:Comedy Movies:10;145:Documentary + Independent Movies:10;146:Drama Movies:10;147:Foreign Movies:10;148:Horror Movies:10;149:Musical Movies:10;150:Romance Movies:10;151:Sci-Fi + Fantasy Movies:10;152:Sports Movies:10;153:TV Shows:10;154:Thriller Movies:10;155:Classical Music:10;156:Country Music:10;157:Electronic-Dance Music:10;158:Hip Hop Music:10;159:Jazz Music:10;160:Kids Music:10;161:Reggae Music:10;162:Rock Music:10;163:Soundtrack Music:10;164:Action Adventure Video Games:10;165:Arcade/ Puzzle Video Games:10;166:Family/ Party Video Games:10;167:Fighting Video Games:10;168:Music/ Dance Video Games:10;169:Racing Video Games:10;170:RPG Video Games:10;171:Shooter Video Games:10;172:Sports Video Games:10;173:Strategy/ Sim Video Games:10".split(';')
  # office, photos + music gear - 11
    arr_o_arr[arr_o_arr.count] = "174:Conference Tables:11;175:Desks + Desk Hutches:11;176:Filing Cabinets:11;177:Home Office Accessories:11;178:Guitars:11;179:Bass Guitars:11;180:Drums + Percussion:11;181:Microphones + Vocal Equipment:11;182:Live Sound Equipment:11;183:Amplifiers + Effects:11;184:Keyboards + MIDI:11;185:Recording + Pro Audio Equipment:11;186:DJ + Lighting:11;187:Folk, Band + Orchestra:11;188:Office Chairs :11;189:A/V Presentation Equipment:11;190:Binoculars + Scopes:11;191:Camcorders:11;192:Darkroom Equipment + Accessories:11;193:Digital Cameras + Gear:11;194:Film, Tapes + Media:11;195:Lighting + Studio Equipment:11;196:Underwater Photo/Video Equipment:11;197:Video Professional Equipment:11".split(';')
  # tickets + coupons - 13
    arr_o_arr[arr_o_arr.count] = "231:Alternative Rock Concerts:13;232:Art + Musical Tickets:13;233:Basketball Events:13;234:Classical Concerts:13;235:Family Tickets:13;236:Hockey Events:13;237:Jazz and Blues Concerts:13;238:Motorsport Events:13;239:Rock and Pop Concerts:13;240:Soccer Events:13;241:Volleyball Events:13;242:Automotive Coupons:13;243:Entertainment Coupons:13;244:Foods Coupons:13;245:Health Care Coupons:13;246:Home Entertainment Coupons:13;247:Personal Care Coupons:13".split(';')
  # vehicles + parts - 14
    arr_o_arr[arr_o_arr.count] = "248:Antique Cars:14;249:Auto Parts + Accessories:14;250:Classic Cars:14;251:Custom Cars:14;252:Fishing Boats:14;253:Hot Rods:14;254:Imported Cars:14;255:Economy Cars:14;256:Premium Compact Segment Cars:14;257:Entry-level Luxury Cars:14;258:Mid-luxury/Executive Cars:14;259:High-End Luxury Cars:14;260:Motorcycles Cruiser:14;261:Motorcycles Off-Road:14;262:Motorcycles Sportbike:14;263:Motorcycles Touring:14;264:Motorcycles Vintage:14;265:Off-Road Powersports:14;266:Pontoon Boats:14;267:Sailboats:14;268:Scooters:14;269:Street Rods:14;270:Towboats:14;271:Watercraft:14;272:Yachts:14".split(';')

  # SERVICES
  # accounting + finance - 15
    arr_o_arr[arr_o_arr.count] = "273:Accounting Services:15;274:Bankruptcy Filing:15;275:Bookkeeping Services:15;276:Divorce Filing:15;277:Financial Advice:15;278:Income Tax Services:15;279:Legal Services:15;280:Name Change Filing:15;281:New Business Startup:15;282:Payroll Processing:15;283:Prenuptial Agreements:15".split(';')
  # architecture + engineering - 16
    arr_o_arr[arr_o_arr.count] = "284:Architecture Consulting:16;285:Bedroom Design:16;286:Landscape Architecture:16;287:Office and Warehouse Design:16;288:Office Interior Design:16;289:Store Design & Building:16;290:Electrical Engineering:16;291:Manufacturing Engineering:16;292:Mechanical Engineering :16;293:Quality Engineering:16;294:Safety Engineering:16;295:Software Engineering:16".split(';')
  # art, media + web design - 17
    arr_o_arr[arr_o_arr.count] = "296:Animation & Special Effects Services:17;297:Audio Production Services:17;298:Film Production Services:17;299:Game Design & Programming Services:17;300:Interactive Media Services:17;301:Photography Services:17;302:Video Production Services:17;303:Web Design:17".split(';')
  # beauty + fitness - 18
    arr_o_arr[arr_o_arr.count] = "304:Hair Cut/Color/Style Services:18;305:Makeup Services:18;306:Massage Services:18;307:Nail Services:18;308:Spa Treatments:18;309:Personal Training Services:18;310:Medical Services:18;311:Dental Services:18;312:Men's Barber:18".split(';')
  # business + consulting - 19
    arr_o_arr[arr_o_arr.count] = "313:Administrative Services:19;314:Banking Services:19;315:Business Consulting:19;316:Data Entry Services:19;317:Design Consulting:19;318:Insurance Services:19;319:Office Cleaning Services:19;320:Office Help Tasks:19;321:Office Organization Services:19;322:Tech Industry Consulting:19;323:Usability Testing:19;324:Wedding, Parties + Entertainment:19".split(';')
  # coaches + therapists - 20
    arr_o_arr[arr_o_arr.count] = "325:Family Therapy:20;326:General Counseling:20;327:Life Coaching:20;328:Physical Therapy:20;329:Spiritual Counseling:20;330:Spiritual Healer:20;331:Sports Coach:20".split(';')
  # dental, legal, + medical - 21
    arr_o_arr[arr_o_arr.count] = "475:Bankruptcy:21;476:Divorce:21;477:Name Change:21;478:Prenuptial Agreements:21".split(';')
  # programmers + developers - 26
    arr_o_arr[arr_o_arr.count] = "373:Web Application Front End:25;374:Web Application Back End:25;375:iOS App Development:25;376:Android App Development:25;377:Windows Phone Development:25;378:Kindle Fire App Development:25;379:Mac OS X App Development:25;380:Windows App Development:25".split(';')
  # education + tutoring - 22
    arr_o_arr[arr_o_arr.count] = "332:Algebra 1 & 2:22;333:Calculus (Thru A.P.):22;334:Geometry:22;335:Pre-Algebra:22;336:Pre-Calculus:22;337:Statistics (Thru A.P.):22;338:Trigonometry:22;339:English (Thru A.P.):22;340:Comprehension + Reading Skills:22;341:Grammar + Vocabulary + Spelling:22;342:Literature (Thru A.P.):22;343:Writing Skills + Handwriting + Punctuation  :22;344:ESL + Phonics:22;345:U.S. History (Thru A.P.):22;346:World History:22;347:Social Studies:22;348:European History (Thru A.P.):22;349:Economics (Thru A.P.):22;350:Philosophy:22;351:Government (Thru A.P.):22;352:Political Science:22;353:Biology (Thru A.P.):22;354:Chemistry (Thru A.P.):22;355:Physics (Thru A.P.):22;356:Environmental (Thru A.P.):22;357:Life Science:22;358:Physical Science:22;359:General Science:22;360:Physiology:22;361:Spanish Language:22;362:French Language:22;363:Latin Language:22;364:Graduate Admissions Tutor:22;365:College Admissions Tutor:22;366:Medical Licensing Tutor:22;367:Bar Review Tutor:22;368:Standardized Testing Preparation:22".split(';')
  # general + misc - 24
  # vehicles repair + maintenance - 25
  arr_o_arr[arr_o_arr.count] = "381:Boat Repair + Maintenance:26;382:Car + Truck Repair + Maintenance:26;383:Motorcycle Repair + Maintenance:26;384:Powersport Repair + Maintenance:26".split(';')
  # food, nutrition + hospitality - 23
    arr_o_arr[arr_o_arr.count] = "369:Cooking Services:23;370:Holistic Nutrition:23;371:Nutrition Consulting:23;372:Weight Loss:23".split(';')

  # INTERESTS
  # Sports You Play or Teach - 386
    arr_o_arr[arr_o_arr.count] = "389:Backpacking:386;390:Baseball:386;391:Basketball:386;392:Camping:386;393:Cars (Motorsports):386;394:Football:386;395:Golf:386;396:Hiking:386;397:Hockey:386;398:Martial Arts:386;399:Motorcycles (Motorsports):386;400:Mountain Cycling:386;401:Pilates:386;402:Road Cycling:386;403:Running:386;404:Rock climbing:386;405:Skiing:386;406:Soccer:386;407:Swimming:386;408:Tennis:386;409:Yoga:386".split(';')
  # Hobbies You're Into - 387
    arr_o_arr[arr_o_arr.count] = "410:Animal Care:387;411:Beach:387;412:Beer:387;413:Billiards:387;414:Boating:387;415:Bowling:387;416:Chess:387;417:Church Activities:387;418:Coffee:387;419:Coin Collector:387;420:Collect Autographs:387;421:Collect Dolls:387;422:Comic Book, Graphic Novel, Zine Collector:387;423:Commemorative + Souvenir Collector:387;424:Computer:387;425:Cooking:387;426:Crafts:387;427:Dancing:387;428:DJ/Computer:387;429:Drums:387;430:Entertaining:387;431:Figurines + Sci-Fi Collector:387;432:Fishing:387;433:Flute:387;434:Gardening:387;435:Guitar:387;436:Home Improvement:387;437:Horseback Riding:387;438:Hunting:387;439:In a Band:387;440:Keyboard:387;441:Listening to Music:387;442:Painting:387;443:Piano:387;444:Playing Cards:387;445:Playing Music:387;446:Reading:387;447:Relaxing:387;448:Renting Movies:387;449:Saxophone:387;450:Sewing:387;451:Singing:387;452:Sleeping:387;453:Sports Fanatic:387;454:Stamps and Certificate Collector:387;455:Tea:387;456:Theater:387;457:Traveling:387;458:Violin:387;459:Walking:387;460:Wine:387;461:Woodworking:387;462:Working on Cars:387;463:Writing:387".split(';')
  # You Going Out - 388
    arr_o_arr[arr_o_arr.count] = "464:Art/Museums:388;465:Eating out:388;466:Going to bars:388;467:Going to clubs:388;468:Going to movies:388;469:Hanging out with friends:388;470:Playing music:388;471:Religious/Spiritual:388;472:Shopping:388;473:Volunteer work:388;474:Watching sports:388".split(';')

  # # New category added in Goods and Services
  #   arr_o_arr[arr_o_arr.count] = "479:\"I am not sure\":2".split(',')
  #   arr_o_arr[arr_o_arr.count] = "480:\"I am not sure\":3".split(',')

    arr_o_arr.each do |arr|
      arr.each do |c|
        r = c.split(':')
        begin
          cat = Category.new(:id => r[0].to_i, :name => r[1], :category_id => r[2].to_i)
          cat.imageURL = r[3] unless(r.size < 4)
          cat.save
        rescue StandardError => e
          puts e.message
          puts "Already exists: " + c
        end
      end
    end

    system("curl 'http://#{DOMAIN}/clear_category_cache'")
  end

# rake purge orphan photos of item and user
  task :purge_orphan_photos => :environment do
    # Clear out any photo records that have not been assigned to a particular
    # item or user within the span of one day.
    UserPhoto.destroy_all([ 'created_at < ? AND user_id IS NULL', 1.days.ago ])
    ItemPhoto.destroy_all([ 'created_at < ? AND item_id IS NULL', 1.days.ago ])
  end

# rake Send mail to publisher that ur offer going to expire
  task :temp => [:environment] do
  end

  # rake task to update users' friend lists.
  # task :update_friend_lists => :environment do
  #   users = User.find(:all,:conditions => {:active => true})
  #   users.each do |u|
  #     begin
  #       MutualFriend.update_mutual_friends(u)
  #       # User.update_friend_list(u.id)
  #     rescue
  #     end
  #   end
  # end

  # rake task to update users' column showed_onboarding
  task :update_showed_onboarding => :environment do
    users = User.find(:all)
    users.each do |u|
      begin
        if ((u.goods_sub_cat_ids.size > 0) or (u.services_sub_cat_ids.size > 0) or (u.interests_sub_cat_ids.size > 0))
          u.showed_onboarding = true
          u.save
        end
      rescue
      end
    end
  end

  # rake task to update users' friend lists.
  # task :update_mutual_friends => :environment do
  #   users = User.find(:all,:conditions => {:active => true})
  #   users.each do |u|
  #     begin
  #       MutualFriend.update_mutual_friends(u)
  #     rescue
  #     end
  #   end
  # end

  # rake task to update old status values for table trades  
  task :update_old_status_trades => :environment do
    trades = Trade.where("status is null")
    trades.each do |t|
      begin
        if t.accepted_offer.present?
          t.status = "ACCEPTED"
        else
          t.status = "ACTIVE"
        end
        t.save
      rescue
      end
    end
  end

  # rake task to update old status values for table items
  task :update_old_status_items => :environment do
    items = Item.where("status is NULL or status in ('ACTIVE','EXPIRED','INCOMPLETE','POSTPONED')")
    items.each do |i|
      begin
          i.status = "LIVE"
          trades = i.total_trades
          if trades.present?
            trades.each do |t|
              if t.accepted_offer.present?
                i.status = "COMPLETED"
                break
              end
            end
          end
        i.save
      rescue StandardError => e
        puts e.message
        puts e.backtrace.to_s
      end
    end
  end

end