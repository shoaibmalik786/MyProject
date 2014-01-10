class TradesController < ApplicationController
  before_filter :current_location
  cache_sweeper :trade_sweeper, :only => [:create, :update, :destroy, :rate, :delete_offer, :reject]

  # GET /trades
  # GET /trades.json
  def index
    @trades = Trade.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @trades }
    end
  end

  # GET /trades/1
  # GET /trades/1.json
  def show
    if params[:id].present?
      @trade = Trade.find_by_id(params[:id])
      # left user is always the current user on trade page
      if @trade.item.user == current_user
        # my want
        @left_item = @trade.item
        @left_user = current_user
        @right_item = @trade.offer
        @right_user = @trade.offer.user
      else
        # want on my have
        @left_item = @trade.offer
        @left_user = current_user
        @right_item = @trade.item
        @right_user = @trade.item.user
      end
      if @trade.transactions.where("user_id=#{@left_user.id}").present?
        @my_exchange_method = @trade.transactions.where("user_id=#{@left_user.id}").first.exchange_method
        @my_exchange_note = @trade.transactions.where("user_id=#{@left_user.id}").first.exchange_note
        if @trade.transactions.where("user_id=#{@left_user.id}").first.address.present?
          @my_exchange_address = @trade.transactions.where("user_id=#{@left_user.id}").first.address
        end
      end
      if @trade.transactions.where("user_id=#{@right_user.id}").present?
        @trader_exchange_method = @trade.transactions.where("user_id=#{@right_user.id}").first.exchange_method
        @trader_exchange_note = @trade.transactions.where("user_id=#{@right_user.id}").first.exchange_note
        if @trade.transactions.where("user_id=#{@right_user.id}").first.address.present?
          @trader_exchange_address = @trade.transactions.where("user_id=#{@right_user.id}").first.address
        end
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trade }
    end
  end

  # GET /trades/new
  # GET /trades/new.json
  def new
    # New Trade from My Want Flow
    if params[:my_want].present?
      find_trade = Trade.where('item_id'=>params[:my_want].to_i, 'status'=>'PASSIVE').first
      @my_want = Want.where('item_id'=>params[:my_want].to_i, 'user_id'=>current_user.id).first
      if find_trade.present?
        @trade = find_trade
      else
        @trade = Trade.new
        @trade.item_id = @my_want.item_id
        @trade.status = "PASSIVE"
        @trade.save
      end
      redirect_to trade_path(@trade.id) + "?my_want=" + @my_want.id.to_s
    end
  end

  # GET /trades/1/edit
  def edit
    @trade = Trade.find(params[:id])
  end

  # POST /trades
  # POST /trades.json
  def create
    flag = true
    item = Item.find(params[:trades][:item_id])
    offer = Item.find(params[:trades][:offer_id])
    passive_trade = PassiveTrade.find(params[:trades][:passive_trade_id])
    if !item.live? or !offer.live? 
      flag = false
    end
    t = Trade.where(:item_id => item.id, :offer_id => offer.id).where("status != 'REJECTED' and status != 'DELETED'") unless (flag == false)
    if t.present?
      flag = false
    end
    if flag 
      t = Trade.where(:item_id => offer.id, :offer_id => item.id)
      if t.present?
        flag = false
      end
      if flag and current_user and current_user.id == offer.user_id
        trade = Trade.new(params[:trades])
        trade.status = 'ACTIVE'
        trade.save

        passive_trade.trade_comments.each do |tc|
          tc.trade_id = trade.id
          tc.save
        end
        passive_trade.trade_terms.each do |tt|
          tt.trade_id = trade.id
          tt.save
        end
        passive_trade.transactions.each do |t|
          t.trade_id = trade.id
          t.save
        end

        redirect_location = trade_path(trade)
        
        # if (InfoAndSetting.sm_on_o_made and item.user.notify_received_offer)
        #   # Send mail if offer accepted
        #   TradeMailer.offer_made_offerer(offer.id,offer.user.id,item.id,item.user.id).deliver
        #   TradeMailer.offer_made_owner(offer.id,offer.user.id,item.id,item.user.id).deliver
        # end
      end
      # When user moves back rejected offer to offers
      # if flag and params[:undo_reject] == "true"
      #   t = Trade.where(:item_id => item.id, :offer_id => offer.id).where("status = 'REJECTED'").first
      #   if t.present?
      #     t.status = "DELETED"
      #     t.save
      #   end
      #   trade = Trade.new(params[:trade])
      #   trade.status = 'ACTIVE'
      #   trade.save
      #   redirect_location = trade_offers_item_path(item) +"?back_to_offer=true"
      # else
      #   redirect_location = my_offers_item_path(item)
      #   session[:offered_item] = offer.title
      # end
    elsif t.present?
      redirect_location = trade_path(t.first)
    else
      redirect_location = passive_trade_path(passive_trade)
      # session[:offered_item] = offer.title
    end
    
    redirect_to redirect_location
    
    # respond_to do |format|
    #   if @trade.save
    #     format.html { redirect_to @trade, notice: 'Trade was successfully created.' }
    #     format.json { render json: @trade, status: :created, location: @trade }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @trade.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PUT /trades/1
  # PUT /trades/1.json
  def update
    if params[:id].present?
      @trade = Trade.find_by_id(params[:id])
      
      if params[:trades][:new_left_item].present?
        # if @trade.item_id == params[:trades][:left_item]
        #   @trade.item_id = params[:trades][:new_left_item]
        # elsif @trade.offer_id == params[:trades][:left_item]
        #   @trade.offer_id = params[:trades][:new_left_item]
        # end
      elsif params[:trades][:new_right_item].present?
        if @trade.item_id == params[:trades][:right_item].to_i
          @trade.item_id = params[:trades][:new_right_item].to_i
        elsif @trade.offer_id == params[:trades][:right_item].to_i
          @trade.offer_id = params[:trades][:new_right_item].to_i
        end
      end

      @trade.terms_accepted_by_item_user = false
      @trade.terms_accepted_by_offer_user = false
      @trade.status = "ACTIVE"
      @trade.save

      redirect_to trade_path(@trade)
    end
  end

  # DELETE /trades/1
  # DELETE /trades/1.json
  def destroy
    trade = Trade.find(params[:id])
    # if trade.accepted_offer.nil? or current_user.pub?(trade.item)
      # trade.destroy
    # else
      trade.update_attribute("status", "DELETED")
    # end

    # Alert.add_2_alert_q(ALERT_TYPE_TRADEYA, OFFER_DELETED, trade.item.user.id, nil, trade.id)
    
    #mail notification (Mohammad Faizan)
    # if trade.item.user.notify_offer_changed?(MAIL) then EventNotificationMailer.offer_on_tradeya_deleted(trade.item,trade.offer).deliver end
    if trade.item.user.notify_offer_changed then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_OFFER_ON_TRADEYA_DELETED, trade.item.user.id, {:trade_id => trade.id}) end

    if params[:manageOffer]
      if params[:manageOffer] == "SUCCESSFUL"
        @successfulOffers = Trade.get_user_successful_offers(current_user.id)
      elsif params[:manageOffer] == "PAST"
        @pastOffers = Trade.get_user_past_offers(current_user.id)
      elsif params[:manageOffer] == "CURRENT"
        @currentOffers = Trade.get_user_current_offers(current_user.id)
      end
    else
      @item = trade.item
      #@trades = @item.trades
      @userReviews = User.get_user_reviews(@item.user_id)
      @comments = Comment.item_comments(@item.id)
      @accepted_offers = @item.accepted_trades
      @trades = @item.other_trades
    
      @status = @item.item_status
    
      @offererReviews = Array.new
      @trades.each do |trade|
        offerer = trade.offer.user_id
        @offererReviews.push(User.get_user_reviews(offerer))
      end

      #Generating Reviews about accepted offerers 
      @accepted_offererReviews = Array.new
      @accepted_offers.each do |trade|
        offerer = trade.offer.user_id
        @accepted_offererReviews.push(User.get_user_reviews(offerer))
      end
    
      @offer_open4cats = @item.offer_open4cats

      @pub = false
      @offerer = false

      if current_user
        @pub = current_user.pub?(@item)
        @offerer = current_user.offerer?(@item.id)
      end

      # Generating mutual connections
      @mc = Hash.new  #mutual connections
      @amc = Hash.new  #accepted mutual connections
      @offerer_mc = [] #offerer or potential offerer's mutual connection with item owner
      if @pub 
        @trades.each do |trade|
          if !@mc[trade.offer.user.id] or @mc[trade.offer.user.id].nil?
            @mc[trade.offer.user.id] = MutualFriend.get_mutual_friends_details(current_user.id, trade.offer.user.id)
            # connections = fb_mutual_friends(current_user,trade.offer.user)
            # connections.concat(twitter_mutual_friends(current_user,trade.offer.user))
            # @mc[trade.offer.user.id] = connections
          end
        end
        @accepted_offers.each do |trade|
          if !@amc[trade.offer.user.id] or @amc[trade.offer.user.id].nil?
            @amc[trade.offer.user.id] = MutualFriend.get_mutual_friends_details(current_user.id, trade.offer.user.id)
            # connections = fb_mutual_friends(current_user,trade.offer.user)
            # connections.concat(twitter_mutual_friends(current_user,trade.offer.user))
            # @amc[trade.offer.user.id] = connections
          end
        end
      elsif current_user
        # offerer or potential offerer's mutual connection with item owner
        # connections = fb_mutual_friends(current_user,@item.user)
        # connections.concat(twitter_mutual_friends(current_user,@item.user))
        # @offerer_mc = connections
        @offerer_mc = MutualFriend.get_mutual_friends_details(current_user.id, @item.user.id)
      end
    end
    render :layout => false
  end

  # POST
  def rate
    # @trade= Trade.find(params[:id])
    # params[:isDivOpen] = true
    # respond_to do |format|
    #   if @trade.rate(params[:stars], current_user)
    #     Alert.add_2_alert_q(ALERT_TYPE_OFFER, OFFER_RATED, @trade.offer.user.id, nil, @trade.id)

    #     # if InfoAndSetting.sm_on_rated_ur_i then EventNotificationMailer.rated_your_item(@trade).deliver end
    #     # if InfoAndSetting.sm_on_rated_ur_i then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_RATED_YOUR_ITEM, @trade.offer.user.id, {:trade_id => @trade.id}) end
    #     if InfoAndSetting.sm_on_rated_ur_i and @trade.offer.user.notify_received_comments then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_RATED_YOUR_ITEM, @trade.offer.user.id, {:trade_id => @trade.id}) end
    #     if InfoAndSetting.sm_on_o_higher_than_ur
    #       @trade.item.trades.each do |t|
    #         if @trade.id != t.id and t.rating_average.to_f > 0.0
    #           if @trade.rating_average.to_f > t.rating_average.to_f
    #             # EventNotificationMailer.someone_offer_higher_than_yours(t).deliver
    #             if @trade.offer.user.notify_received_comments then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_SOMEONE_OFFER_HIGHER_THAN_YOURS, t.offer.user.id, {:trade_id => t.id}) end
    #           end
    #         end
    #       end
    #     end

    #     @item = @trade.item
    #     @status = @item.item_status

    #     @pub = false
    #     @offerer = false
    #     if current_user
    #       @pub = current_user.pub?(@item)
    #       @offerer = current_user.offerer?(@item.id)
    #     end

    #     #Generating mutual connections
    #     @mc = Hash.new  #mutual connections
    #     @amc = Hash.new  #accepted mutual connections
    #     @offerer_mc = [] #offerer or potential offerer's mutual connection with item owner
    #     @accepted_offers = @item.accepted_trades
    #     @trades = @item.other_trades

    #     if @trade.accepted_offer.nil?
    #       @accepted = false

    #       #Generating Reviews about offerers 
    #       @offererReviews = Array.new
    #       @trades.each do |trade|
    #         offerer = trade.offer.user_id
    #         @offererReviews.push(User.get_user_reviews(offerer))
    #       end

    #       if @pub and current_user
    #         @trades.each do |trade|
    #           if !@mc[trade.offer.user.id] or @mc[trade.offer.user.id].nil?
    #             @mc[trade.offer.user.id] = MutualFriend.get_mutual_friends_details(current_user.id, trade.offer.user.id)
    #             # connections = fb_mutual_friends(current_user,trade.offer.user)
    #             # connections.concat(twitter_mutual_friends(current_user,trade.offer.user))
    #             # @mc[trade.offer.user.id] = connections
    #           end
    #         end
    #       elsif current_user
    #         #offerer or potential offerer's mutual connection with item owner
    #         # connections = fb_mutual_friends(current_user,@item.user)
    #         # connections.concat(twitter_mutual_friends(current_user,@item.user))
    #         # @offerer_mc = connections
    #         @offerer_mc = MutualFriend.get_mutual_friends_details(current_user.id, @item.user.id)
    #       end
    #     else
    #       @accepted = true

    #       #Generating Reviews about accepted offerers 
    #       @accepted_offererReviews = Array.new
    #       @accepted_offers.each do |trade|
    #         offerer = trade.offer.user_id
    #         @accepted_offererReviews.push(User.get_user_reviews(offerer))
    #       end
    #       if @pub and current_user
    #         @accepted_offers.each do |trade|
    #           if !@amc[trade.offer.user.id] or @amc[trade.offer.user.id].nil?
    #             @amc[trade.offer.user.id] = MutualFriend.get_mutual_friends_details(current_user.id, trade.offer.user.id)
    #             # connections = fb_mutual_friends(current_user,trade.offer.user)
    #             # connections.concat(twitter_mutual_friends(current_user,trade.offer.user))
    #             # @amc[trade.offer.user.id] = connections
    #           end
    #         end
    #       elsif current_user
    #         #offerer or potential offerer's mutual connection with item owner
    #         # connections = fb_mutual_friends(current_user,@item.user)
    #         # connections.concat(twitter_mutual_friends(current_user,@item.user))
    #         # @offerer_mc = connections
    #         @offerer_mc = MutualFriend.get_mutual_friends_details(current_user.id, @item.user.id)
    #       end
    #     end

    #     format.js {}
    #   else
    #     @item = @trade.item
    #     @status = @item.item_status
    #     @userReviews = User.get_user_reviews(@item.user_id)

    #     @pub = false
    #     @offerer = false
    #     if current_user
    #       @pub = current_user.pub?(@item)
    #       @offerer = current_user.offerer?(@item.id)
    #     end

    #     #Generating mutual connections
    #     @mc = Hash.new  #mutual connections
    #     @amc = Hash.new  #accepted mutual connections
    #     @offerer_mc = [] #offerer or potential offerer's mutual connection with item owner

    #     if @trade.accepted_offer.nil?
    #       @accepted = false
    #       @trades = @item.other_trades

    #       #Generating Reviews about offerers 
    #       @offererReviews = Array.new
    #       @trades.each do |trade|
    #         offerer = trade.offer.user_id
    #         @offererReviews.push(User.get_user_reviews(offerer))
    #       end

    #       if @pub and current_user
    #         @trades.each do |trade|
    #           if !@mc[trade.offer.user.id] or @mc[trade.offer.user.id].nil?
    #             @mc[trade.offer.user.id] = MutualFriend.get_mutual_friends_details(current_user.id, trade.offer.user.id)
    #             # connections = fb_mutual_friends(current_user,trade.offer.user)
    #             # connections.concat(twitter_mutual_friends(current_user,trade.offer.user))
    #             # @mc[trade.offer.user.id] = connections
    #           end
    #         end
    #       elsif current_user
    #          @offerer_mc = MutualFriend.get_mutual_friends_details(current_user.id, @item.user.id)
    #         #offerer or potential offerer's mutual connection with item owner
    #         # connections = fb_mutual_friends(current_user,@item.user)
    #         # connections.concat(twitter_mutual_friends(current_user,@item.user))
    #         # @offerer_mc = connections
    #       end
    #     else
    #       @accepted = true
    #       @accepted_offers = @item.accepted_trades

    #       #Generating Reviews about accepted offerers 
    #       @accepted_offererReviews = Array.new
    #       @accepted_offers.each do |trade|
    #         offerer = trade.offer.user_id
    #         @accepted_offererReviews.push(User.get_user_reviews(offerer))
    #       end

    #       if @pub and current_user
    #         @accepted_offers.each do |trade|
    #           if !@amc[trade.offer.user.id] or @amc[trade.offer.user.id].nil?
    #             @amc[trade.offer.user.id] = MutualFriend.get_mutual_friends_details(current_user.id, trade.offer.user.id)
    #             # connections = fb_mutual_friends(current_user,trade.offer.user)
    #             # connections.concat(twitter_mutual_friends(current_user,trade.offer.user))
    #             # @amc[trade.offer.user.id] = connections
    #           end
    #         end
    #       elsif current_user
    #          @offerer_mc = MutualFriend.get_mutual_friends_details(current_user.id, @item.user.id)
    #         #offerer or potential offerer's mutual connection with item owner
    #         # connections = fb_mutual_friends(current_user,@item.user)
    #         # connections.concat(twitter_mutual_friends(current_user,@item.user))
    #         # @offerer_mc = connections
    #       end
    #     end

    #     format.js {}
    #   end
    # end
  end

  def delete_offer
    msg = 'deleted'
    begin
        i = Item.find(params[:id])
        if i then i.destroy end
    rescue StandardError => e
      puts "Something went wrong while deleting trade or offer."
      msg = 'Unable to delete.'
    end
    render :text => msg
  end

  def reject
    if params[:id].present?
      trade = Trade.find params[:id]
      item = trade.item
      offer = trade.offer
      if current_user and current_user.id == trade.item.user_id
        trade.status = 'REJECTED'
        trade.save
        # Send mail if offer rejected
        TradeMailer.offer_rejected_offerer(offer.id,offer.user.id,item.id,item.user.id).deliver
      end
    end
    redirect_to trade_offers_item_path(item, :reject_of => offer.user.first_name.titleize)
  end

  def my_haves_tab
    if params[:id].present?
      @trade = Trade.find_by_id(params[:id])
      @my_haves = current_user.have_items
    end
  end

  def communication_tab
    if params[:id].present?
      @trade = Trade.find_by_id(params[:id])
      @trade_comments = @trade.trade_comments
      @trade_terms = @trade.trade_terms

      # Exchange Methods
      if @trade.item.user == current_user
        @left_user = current_user
        @right_user = @trade.offer.user
      else
        @left_user = current_user
        @right_user = @trade.item.user
      end
      if @trade.transactions.where("user_id=#{@left_user.id}").present?
        @my_exchange_method = @trade.transactions.where("user_id=#{@left_user.id}").first.exchange_method
        @my_exchange_note = @trade.transactions.where("user_id=#{@left_user.id}").first.exchange_note
        if @trade.transactions.where("user_id=#{@left_user.id}").first.address.present?
          @my_exchange_address = @trade.transactions.where("user_id=#{@left_user.id}").first.address
        end
      end
      if @trade.transactions.where("user_id=#{@right_user.id}").present?
        @trader_exchange_method = @trade.transactions.where("user_id=#{@right_user.id}").first.exchange_method
        @trader_exchange_note = @trade.transactions.where("user_id=#{@right_user.id}").first.exchange_note
        if @trade.transactions.where("user_id=#{@right_user.id}").first.address.present?
          @trader_exchange_address = @trade.transactions.where("user_id=#{@right_user.id}").first.address
        end
      end
    end
  end

  def trader_haves_tab
    if params[:id].present?
      @trade = Trade.find_by_id(params[:id])
      @trader_haves = @trade.item.user.have_items
    end
  end

  def confirm
    @trade = Trade.find(params[:id])
    @user = @trade.item.user
  end
  
  def complete
    
  end

  def accept_terms
    if params[:id].present?
      @trade = Trade.find(params[:id])
      if @trade.item.user_id == current_user.id
        @trade.terms_accepted_by_item_user = true
      else
        @trade.terms_accepted_by_offer_user = true
      end 
      @trade.save

      if @trade.terms_accepted_by_item_user == true and @trade.terms_accepted_by_offer_user == true
        @trade.status = "COMPLETED"
        @trade.save
        redirect_to trade_transactions_path(@trade)+"/"+@trade.transactions.where("user_id=#{current_user.id}").first.id.to_s
      else
        @trade.status = "PENDING"
        @trade.save
        redirect_to active_trades_user_path(current_user)
      end
    end
  end

end
