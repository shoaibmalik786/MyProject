class AddressesController < ApplicationController
	before_filter :authenticate_user_from_token!
	def index 
		addresses = Address.where(:user_id => current_user.id)

		render :status => 200,
           :json => { :success => true,
                      :addresses => addresses
                    }
	end

	def create
		# debugger
		clear_current(params[:current])
		address = Address.create(:address_line_1 => params[:address_line_1],
								   :address_line_2 => params[:address_line_2],
								   :city => params[:city],
								   :state => params[:state],
					               :country  => params[:country],
					               :zipcode => params[:zipcode],
					               :name => params[:name],
					               :phone => params[:phone],
					               :email => params[:email],
					               :current => true,
					               :user_id => current_user.id
              )
		
		address.save

		success = true
		if address.errors.full_messages.size > 0
			success = false
		end

		render :status => 200,
           :json => { :success => success,
                      :data => {} }
	end

	def update
		address = Address.find_by_id(params[:id])
		# debugger
		clear_current(params[:current])

		unless address.nil?
			address.address_line_1 = params[:address_line_1] unless params[:address_line_1].nil?
			address.address_line_2 = params[:address_line_2] unless params[:address_line_2].nil?
			address.city = params[:city] unless params[:city].nil?
			address.state = params[:state] unless params[:state].nil?
			address.country = params[:country] unless params[:country].nil?
			address.zipcode = params[:zipcode] unless params[:zipcode].nil?
			address.name = params[:name] unless params[:name].nil?
			address.phone = params[:phone] unless params[:phone].nil?
			address.email = params[:email] unless params[:email].nil?
			address.current = params[:current] unless params[:current].nil?
			address.save
		else
			success = false
		end

		render :status => 200,
           :json => { :success => success,
                      :data => {} }
	end

	def destroy
		# debugger
		address = Address.find_by_id(params[:id])

		unless address.nil?
			if address.current
				address_current = Address.where(:user_id => current_user.id).last
				address_current.current = true
				address_current.save!
			end
			address.destroy
			success = true
			if address.errors.full_messages.size > 0
				success = false
			end
		else
			success = false
		end
		
		render :status => 200,
           :json => { :success => success,
                      :data => {} }

	end

	def clear_current(current)
		unless current.nil?
			# debugger
			address_current = Address.where(:user_id => current_user.id, :current => true)
			address_current.each do | address |
				address.current = false
				address.save
			end
		end
	end
end