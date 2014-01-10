class AcceptedOffersController < ApplicationController
  before_filter :current_location
  # before_filter :require_user
  before_filter :authenticate_user!
  cache_sweeper :accept_offer_sweeper, :only => [:create, :update, :destroy, :accept_multiple_offers]
  # GET /accepted_offers
  # GET /accepted_offers.json
  def index
    @accepted_offers = AcceptedOffer.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @accepted_offers }
    end
  end

  # GET /accepted_offers/1
  # GET /accepted_offers/1.json
  def show
    @accepted_offer = AcceptedOffer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @accepted_offer }
    end
  end

  # GET /accepted_offers/new
  # GET /accepted_offers/new.json
  def new
    @accepted_offer = AcceptedOffer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @accepted_offer }
    end
  end

  # GET /accepted_offers/1/edit
  def edit
    @accepted_offer = AcceptedOffer.find(params[:id])
  end

  # POST /accepted_offers
  # POST /accepted_offers.json

  #TODO: Mail for review is commented.

  def create
    if params[:trade_id]
      trade = Trade.find params[:trade_id]
      item = trade.item
      offer = trade.offer
      if current_user and trade.item.user_id == current_user.id
        if trade.active?
          accepted_offer = AcceptedOffer.new
          accepted_offer.trade_id = params[:trade_id]
          accepted_offer.user_id = current_user.id
          accepted_offer.recent_tradeya = true
          if accepted_offer.save
            trade.update_attribute(:status, "ACCEPTED")
            item.reduce_quantity
            offer.reduce_quantity
            copy2me = (params[:copy2me] == 'true')
            # this is an immediate notification with Publisher's message
            #EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_OFFER_ACCEPTED, offer.user_id, {:trade_id => trade.id, :msg => params[:msg], :copy2me => copy2me, :chk_user_setting => true})
            TradeMailer.offer_accepted_offerer(offer.id,offer.user.id,item.id,item.user.id).deliver
            TradeMailer.offer_accepted_owner(offer.id,offer.user.id,item.id,item.user.id).deliver
            TradeMailer.review_reminder_offerer(offer.user.id,item.user.id).deliver_in(3.days)
            TradeMailer.review_reminder_owner(offer.user.id,item.user.id).deliver_in(3.days)
            # to show count of offers accepted in daily or weekly notification mails
            EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_OFFER_ACCEPTED, offer.user_id, {:trade_id => trade.id, :msg => params[:msg], :copy2me => copy2me}) unless (offer.user.notification_frequency == NOTIFICATION_FREQUENCY_IMMEDIATE or !offer.user.notify_offer_accepted)
            
            # Alert.add_2_alert_q(ALERT_TYPE_OFFER, OFFER_ACCEPTED, offer.user_id, nil, trade.id)
          end
        end
      end
      # if item.completed?
        # redirect_to accepted_offers_item_path(item)
      # else
        # redirect_to trade_offers_item_path(item)
      # end
      redirect_to past_trades_user_path(current_user,:trade => trade.id)
    end
  end

  def create_old
    tr = Trade.find_by_offer_id(params[:id])
    accepted_offer = AcceptedOffer.new(params[:accepted_offer])
    accepted_offer.user_id = current_user.id
    aos = AcceptedOffer.find_by_trade_id(accepted_offer.trade_id)
    if aos.nil? then accepted_offer.recent_tradeya = true end

    if aos.nil? or (aos.trade_id != accepted_offer.trade_id)
      accepted_offer.trade_id = tr.id
      accepted_offer.user_id = params[:user_id]
      accepted_offer.save
      tr.update_attribute(:status,"ACCEPTED")
      usr_itm = Item.find(accepted_offer.trade.item_id)
      # usr_itm.update_attribute("status","COMPLETED") if usr_itm.is_single_tradeya
      if usr_itm.qty_unlimited

      else
        usr_itm.quantity = usr_itm.quantity - 1
        if usr_itm.quantity <= 0 then usr_itm.complete_trade  else usr_itm.save end
      end

      ofr_itm = Item.find(accepted_offer.trade.offer_id)
      if ofr_itm.qty_unlimited

      else
        ofr_itm.quantity = ofr_itm.quantity - 1
        if ofr_itm.quantity <= 0 then ofr_itm.complete_trade  else ofr_itm.save end
      end

      # i = Item.find(params[:item_id])
      copy2me = (params[:copy2me] == 'true')
      
      #for submit a review
      trd = Trade.find(accepted_offer.trade_id)
      
      # trd.update_attribute("single_review_token",token)
      #for submit a review
      
      # EventNotificationMailer.offer_accepted(trd.item, trd.offer, params[:msg]).deliver
      # this is an immediate notification with Publisher's message
      EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_OFFER_ACCEPTED, trd.offer.user.id, {:trade_id => trd.id, :msg => params[:msg], :copy2me => copy2me, :chk_user_setting => true})
      # to show count of offers accepted in daily or weekly notification mails
      EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_OFFER_ACCEPTED, trd.offer.user.id, {:trade_id => trd.id, :msg => params[:msg], :copy2me => copy2me}) unless (trd.offer.user.notification_frequency == NOTIFICATION_FREQUENCY_IMMEDIATE or !trd.offer.user.notify_offer_accepted)
      # EventNotificationMailer.write_review(trd.offer.user.email, trd.item.user, token).deliver
      # EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_WRITE_REVIEW, trd.offer.user.id, {:trade_id => trd.id, :token => offerer_review_token})


      # Alert.add_2_alert_q(ALERT_TYPE_OFFER, OFFER_ACCEPTED, accepted_offer.trade.offer.user.id, nil, accepted_offer.trade.id)
    end
      redirect_to :back
    # render :text => 'Accepted!'
  end

  # PUT /accepted_offers/1
  # PUT /accepted_offers/1.json
  def update
    @accepted_offer = AcceptedOffer.find(params[:id])

    respond_to do |format|
      if @accepted_offer.update_attributes(params[:accepted_offer])
        format.html { redirect_to @accepted_offer, notice: 'Accepted offer was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @accepted_offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accepted_offers/1
  # DELETE /accepted_offers/1.json
  def destroy
    @accepted_offer = AcceptedOffer.find(params[:id])
    @accepted_offer.destroy

    respond_to do |format|
      format.html { redirect_to accepted_offers_url }
      format.json { head :ok }
    end
  end
  
  def update_accept_offer_modal
    @selected =Array.new;
    if params[:selected] and params[:selected].present?
      @item = Item.find(params[:item_id])
      @selected = Item.get_items(params[:selected])
    end
    respond_to do |f|
      f.js
    end
  end
  
  def accept_multiple_offers
    emails = ""
    copy2me = (params[:copy2me] == 'true')
    if params[:item_id] and params[:item_id].present? and params[:trades] and params[:trades].present?
      params[:trades].split(",").each do |trd|
        acc_offer = AcceptedOffer.new
        acc_offer.trade_id = trd
        acc_offer.user_id = current_user.id
        aos = AcceptedOffer.find_by_trade_id(acc_offer.trade_id)
        if aos.nil? then acc_offer.recent_tradeya = true end
        acc_offer.save
        tmp_trade = Trade.find(trd)
        
        #for submit a review
        token = SecureRandom.urlsafe_base64(25) + trd.to_s
        tmp_trade.update_attribute("single_review_token",token)
        #for submit a review
        
        # EventNotificationMailer.offer_accepted(tmp_trade.item, tmp_trade.offer,params[:msg]).deliver
        # this is an immediate notification with Publisher's message
        EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_OFFER_ACCEPTED, tmp_trade.offer.user.id, {:trade_id => tmp_trade.id, :msg => params[:msg], :copy2me => copy2me})
        # to show count of offers accepted in daily or weekly notification mails
        EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_OFFER_ACCEPTED, tmp_trade.offer.user.id, {:trade_id => tmp_trade.id, :msg => params[:msg], :copy2me => copy2me}) unless (tmp_trade.offer.user.notification_frequency == NOTIFICATION_FREQUENCY_IMMEDIATE or !tmp_trade.offer.user.notify_offer_accepted)
        # EventNotificationMailer.write_review(tmp_trade.offer.user.email, tmp_trade.item.user,token).deliver
        EventNotification.add_2_notification_q(NOTIFICATION_TYPE_IMIDIATE, NOTIFICATION_WRITE_REVIEW, tmp_trade.offer.user.id, {:trade_id => tmp_trade.id, :token => token})

        # Alert.add_2_alert_q(ALERT_TYPE_OFFER, OFFER_ACCEPTED, tmp_trade.offer.user.id, nil, tmp_trade.id)
      end
    end
    render :text => "Accepted!"
  end
  
end
