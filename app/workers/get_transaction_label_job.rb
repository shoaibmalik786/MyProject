class GetTransactionLabelJob
  @queue = :labels
  def self.perform(my_transaction_id, oth_transaction_id)
    my_tran = Transaction.find_by_id(my_transaction_id)
    oth_tran = Transaction.find_by_id(oth_transaction_id)

    # do the work to get the label, do not try to get both the labels 
    # since the other users package details may not be available. 
   packages = [
                Package.new( my_tran.weight * 16,                        # lbs, times 16 oz/lb
                            [my_tran.length, my_tran.width, my_tran.height],
                            :units => :imperial)                       # not grams, not centimetres
                
               ]

   options = {
	      :origin => {
	        :address_line1 => my_tran.address.address_line_1, 
	        :country => my_tran.address.country, 
	        :state => my_tran.address.state,
	        :city => my_tran.address.city,
	        :zip => my_tran.address.zipcode, 
	        :phone => my_tran.address.phone, 
	        :name => my_tran.address.name, 
	        #:attention_name => "Receiving Department",
	       	:origin_number => ENV['UPS_ORIGIN_NUMBER']
	        
	      }, 
	      :destination => {
	        :company_name => "N/A",
	        :attention_name => oth_tran.address.name,
	        :phone => oth_tran.address.phone, 
	        :address_line1 => oth_tran.address.address_line_1, 
	        :country => oth_tran.address.country, 
	        :state => oth_tran.address.state, 
	        :city => oth_tran.address.city, 
	        :zip => oth_tran.address.zipcode	
	        }
	      
	    }   

	    @ups = UPS.new(:login => ENV['UPS_LOGIN'], :password => ENV['UPS_PASSWORD'], :key => ENV['UPS_KEY'])
	    label_specification =  {:print_code => "GIF", :format_code => "GIF", :user_agent => "Mozilla/4.5"}
	    confirm_response = @ups.shipment_confirmation_request(my_tran.ship_type_code, packages, label_specification, options)
	    accept_response = @ups.shipment_accept_request(confirm_response.digest)

	    accept_response.shipment_packages.each do |package|

		 html_image = package.html_image 
		  graphic_image = package.graphic_image 
		  label_image_format = package.label_image_format
		  tracking_number = package.tracking_number 
		  label_tmp_file = Tempfile.new("shipping_label")
		   # debugger
      decode_base64_content = Base64.decode64(graphic_image)
      File.open(label_tmp_file, "wb") do |f|
  		f.write(decode_base64_content)
		end
      #label_tmp_file.write(graphic_image)
      label_tmp_file.rewind
      # html_tmp_file = Tempfile.new("shipping_label_html")
      #html_tmp_file.write Base64.decode64(html_image)
      #html_tmp_file.write(html_image)
  #     decode_base64_content_html = Base64.decode64(html_image)
  #     File.open(html_tmp_file, "wb") do |f|
  # 		f.write(decode_base64_content_html)
		# end
      # html_tmp_file.rewind
      graphic_filename = "labels/label#{tracking_number}.#{label_image_format.downcase}"
      gf = File.new(graphic_filename, "wb")
      # debugger
      gf.write File.new(label_tmp_file.path).read
      gf.close
      file1 = File.open(gf.path)
      # debugger
      my_tran.label = file1
      # debugger
      file1.close
      my_tran.save!
      # html_filename = "#{SAVE_LABEL_LOCATION}/#{tracking_number}.html"
      # hf = File.new(html_filename, "wb")
      # hf.write File.new(html_tmp_file.path).read
      # hf.close         

  end
end
end