# This rake file send email to offerers.
# They can be executed as follows:

desc "Set User Lattitude and Longitude."
namespace :location do
# rake Send email to offerers.
  task :set_user_latlng => [:environment] do
    users = User.get_user_with_nolocation
    if users.present?
      users.each do |user|
        puts "#{user.id}: #{user.email}"
        if user.zip.present?
          begin
            # geodata = Geokit::Geocoders::MultiGeocoder.geocode(user.zip)
            geodata = Geocoder.search(user.zip)
            if geodata.count > 0
              geodata = geodata[0]
              if geodata.latitude and geodata.latitude.present? and geodata.longitude and geodata.longitude.present?
                puts "by zip(#{user.zip}): #{geodata.latitude},#{geodata.longitude}"
                user.update_attribute("lat",geodata.latitude)
                user.update_attribute("lng",geodata.longitude)
                user.update_attribute("city",geodata.city)
                user.update_attribute("state",geodata.state_code)
              end
            else
              puts "Failed to geocode. (#{user.zip})"
            end
          rescue
            puts "Failed to geocode. (#{user.zip})"
          end
        elsif user.city.present? and user.state.present?
          begin
            # geodata = Geokit::Geocoders::MultiGeocoder.geocode("#{user.city},#{user.state}")
            geodata = Geocoder.search("#{user.city},#{user.state}")
            if geodata.count > 0
              geodata = geodata[0]
              if geodata.latitude and geodata.latitude.present? and geodata.longitude and geodata.longitude.present?
                puts "by city state(#{user.city},#{user.state}): #{geodata.latitude},#{geodata.longitude}"
                user.update_attribute("lat",geodata.latitude)
                user.update_attribute("lng",geodata.longitude)
              end
            else
              puts "Failed to geocode. (#{user.city},#{user.state})"
            end
          rescue
            puts "Failed to geocode. (#{user.city},#{user.state})"
          end
        elsif user.city.present?
          begin
            # geodata = Geokit::Geocoders::MultiGeocoder.geocode("#{user.city}")
            geodata = Geocoder.search("#{user.city}")
            if geodata.count > 0
              geodata = geodata[0]
              if geodata.latitude and geodata.latitude.present? and geodata.longitude and geodata.longitude.present?
                puts "by city(#{user.city}): #{geodata.latitude},#{geodata.longitude}"
                user.update_attribute("lat",geodata.latitude)
                user.update_attribute("lng",geodata.longitude)
                user.update_attribute("state",geodata.state_code)
              end
            else
              puts "Failed to geocode. (#{user.city})"
            end
          rescue
            puts "Failed to geocode. (#{user.city})"
          end
        end
      end
    end
  end
end