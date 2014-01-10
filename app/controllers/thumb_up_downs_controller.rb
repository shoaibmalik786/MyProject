class ThumbUpDownsController < ApplicationController
  def thumb_up_down
    tud = ThumbUpDown.find_by_token(params[:t])
    if tud
    	if params[:v] == 'up'
      		tud.thumbs_up = true
      		tud.thumbs_down_reason = nil  #reset these values
      		tud.thumbs_down_comment = nil #reset these values
      		tud.save
      		session[:thumbs_up] = true
    	elsif params[:v] == 'down'
    		tud.thumbs_up = false
    		tud.thumbs_down_reason = nil  #reset these values
      		tud.thumbs_down_comment = nil #reset these values
    		tud.save 
    		session[:thumbs_down] = tud.id
    	end
    	redirect_to item_path(tud.item_id)
    else
    	redirect_to '/'
    end
  end

  def thumbs_down_add_reason
  	begin
  		if params[:id] and !params[:id].blank?
  			tud = ThumbUpDown.find_by_id(params[:id])
  			if tud
	  			if params[:option] and !params[:option].blank?
  					tud.thumbs_down_reason = params[:option]
  				end
  				if params[:comment] and !params[:comment].blank?
  					tud.thumbs_down_comment = params[:comment]
  				end
  				tud.save
  			end
  		end
  		render :text => "success"
  	rescue
  		render :text => "error"
  	end
  end

end
