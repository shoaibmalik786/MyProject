class Address < ActiveRecord::Base
  attr_accessible :address_line_2, :address_line_1, :city, :state, :zipcode, :name,
    :country, :current, :lat, :lng, :phone, :email, :user_id
  
  belongs_to :user

  # TODO: Need to add validations
end
