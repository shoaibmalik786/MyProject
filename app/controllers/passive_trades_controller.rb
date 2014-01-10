class PassiveTradesController < InheritedResources::Base
	
	def create
		if params[:passive_trade].present?
			find_pt = PassiveTrade.find_by_item_id_and_user_id(params[:passive_trade][:item_id],params[:passive_trade][:user_id])
			if find_pt.present?
				@passive_trade = find_pt
			else
				pt = PassiveTrade.new(params[:passive_trade])
				pt.status = 'ACTIVE'
				pt.save
				@passive_trade = pt
			end
		end
		# if @passive_trade.trade.present?
		# 	redirect_to trade_path(@passive_trade.trade)
		# else
			redirect_to passive_trade_path(@passive_trade)
		# end
	end

	def show
		if params[:id].present?
			@passive_trade = PassiveTrade.find_by_id(params[:id])
			# left user is always the current user on trade page
			if @passive_trade.user == current_user
				# my want
				@left_item = nil
				@left_user = current_user
				@right_item = @passive_trade.item
				@right_user = @passive_trade.item.user
				if @passive_trade.transactions.where("user_id=#{@right_user.id}").present?
					@trader_exchange_method = @passive_trade.transactions.where("user_id=#{@right_user.id}").first.exchange_method
				end
			else
				# want on my have
				@left_item = @passive_trade.item
				@left_user = current_user
				@right_item = nil
				@right_user = @passive_trade.user
				if @passive_trade.transactions.where("user_id=#{@left_user.id}").present?
					@my_exchange_method = @passive_trade.transactions.where("user_id=#{@left_user.id}").first.exchange_method
				end
			end
			# if @passive_trade.trade.present?
			# 	redirect_to trade_path(@passive_trade.trade)
		 # 	end
		end
	end

	def my_haves_tab
    if params[:id].present?
      @passive_trade = PassiveTrade.find_by_id(params[:id])
      @my_haves = current_user.have_items
      if @passive_trade.user == current_user
				@left_item = nil
				@right_item = @passive_trade.item
			else
				@left_item = @passive_trade.item
				@right_item = nil
			end
    end
  end

  def communication_tab
    if params[:id].present?
      @passive_trade = PassiveTrade.find_by_id(params[:id])
      @trade_comments = @passive_trade.trade_comments
      @trade_terms = @passive_trade.trade_terms
      
      # Exchange Methods
      if @passive_trade.user == current_user
      	@left_user = current_user
				@right_user = @passive_trade.item.user
			else
				@left_user = current_user
				@right_user = @passive_trade.user
			end
			if @passive_trade.transactions.where("user_id=#{@left_user.id}").present?
				@my_exchange_method = @passive_trade.transactions.where("user_id=#{@left_user.id}").first.exchange_method
				@my_exchange_note = @passive_trade.transactions.where("user_id=#{@left_user.id}").first.exchange_note
				if @passive_trade.transactions.where("user_id=#{@left_user.id}").first.address.present?
					@my_exchange_address = @passive_trade.transactions.where("user_id=#{@left_user.id}").first.address
				end
			end
			if @passive_trade.transactions.where("user_id=#{@right_user.id}").present?
				@trader_exchange_method = @passive_trade.transactions.where("user_id=#{@right_user.id}").first.exchange_method
				@trader_exchange_note = @passive_trade.transactions.where("user_id=#{@right_user.id}").first.exchange_note
				if @passive_trade.transactions.where("user_id=#{@right_user.id}").first.address.present?
					@trader_exchange_address = @passive_trade.transactions.where("user_id=#{@right_user.id}").first.address
				end
			end
    end
  end

  def trader_haves_tab
    if params[:id].present?
      @passive_trade = PassiveTrade.find_by_id(params[:id])
      if @passive_trade.user == current_user
				@right_user = @passive_trade.item.user
			else
				@right_user = @passive_trade.user
			end
      @trader_haves = @right_user.have_items
      if @passive_trade.user == current_user
				@left_item = nil
				@right_item = @passive_trade.item
			else
				@left_item = @passive_trade.item
				@right_item = nil
			end
    end
  end

end
