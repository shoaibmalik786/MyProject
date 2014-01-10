require 'rubygems'  
require 'nokogiri'  
require 'open-uri'  

namespace :xml do
  desc "xml build Fetch item details"
  task :item_details => :environment do
    item_details_xml
  end 
end

def item_details_xml
  # build xml docoument
  Category.root.categories.each do |main_category|
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.Category("name"=>main_category.name){
        main_category.categories.each do |sub_category|
          xml.Subcategory("name"=>sub_category.name){
            sub_category.items.each do |item|
              xml.Item{
                xml.title item.title
                xml.description item.desc
                xml.URL item.item_url
              }
            end
          }
        end
      }  
    end
    File.open("#{Rails.root}/public/#{main_category.name}.xml", 'w') {|f| f.write(builder.to_xml) }
  end
end