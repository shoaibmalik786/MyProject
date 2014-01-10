require 'base64'
require 'fileutils'
require 'tempfile'
require 'active_shipping'

include ActiveMerchant::Shipping

class TransactionsController < ApplicationController 
   before_filter :authenticate_user!
  
  # GET /transactions
  # GET /transactions.json
  def index
    @transaction = Transaction.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @trades }
    end
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
    @trade = Trade.find(params[:trade_id])
    @left_item = @trade.item
    @right_item = @trade.offer
    @trade_terms = @trade.trade_terms
    if @trade.item.user_id == current_user.id
      @my_transaction = @trade.transactions.where(user_id: @trade.item.user_id ).first
      @oth_transaction = @trade.transactions.where(user_id: @trade.offer.user_id).first
    else
      @my_transaction = @trade.transactions.where(user_id: @trade.offer.user_id).first
      @oth_transaction = @trade.transactions.where(user_id: @trade.item.user_id ).first
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @transaction }
    end
  end

  # GET /transactions/new
  # GET /transactions/new.json
  def new
    @transaction = Transaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @transaction }
    end
  end

  # GET /transactions/1/edit
  def edit
    @transaction = Transaction.find(params[:id])
  end

  # POST /transactions
  # POST /transactions.json
  def create
    if params[:passive_trade_id].present?
      @passive_trade = PassiveTrade.find(params[:passive_trade_id])
      @pt_trans = Transaction.where("passive_trade_id=#{@passive_trade.id} and user_id=#{current_user.id}").first
      if !@pt_trans.present?
        @pt_trans = @passive_trade.transactions.new(params[:transactions])  
        @pt_trans.user_id = current_user.id
      end
      
      @pt_trans.exchange_method = params[:transactions][:exchange_method]
      @pt_trans.exchange_date = params[:transactions][:exchange_date]
      @pt_trans.exchange_time = params[:transactions][:exchange_time]
      @pt_trans.exchange_note = params[:transactions][:exchange_note] 
      
      # Save Address
      if params[:addresses].present?
        @my_address = Address.find_by_id(@pt_trans.address_id)
        if !@my_address.present?
          @my_address = Address.new(params[:addresses])
          @my_address.user_id = current_user.id
          @my_address.email = current_user.email
          @my_address.save
          @pt_trans.address_id = @my_address.id  
        else
          @my_address.update_attributes(params[:addresses])
          @my_address.save
        end
      end
      @pt_trans.save  
      if @passive_trade.transactions.where("user_id=#{current_user.id}").present?
        @my_exchange_method = @passive_trade.transactions.where("user_id=#{current_user.id}").first.exchange_method
      end
    elsif params[:trade_id].present?
      @trade = Trade.find(params[:trade_id])
      @pt_trans = Transaction.where("trade_id=#{@trade.id} and user_id=#{current_user.id}").first
      if !@pt_trans.present?
        @pt_trans = @trade.transactions.new(params[:transactions])  
        @pt_trans.user_id = current_user.id
      end
      @pt_trans.exchange_method = params[:transactions][:exchange_method]
      @pt_trans.exchange_date = params[:transactions][:exchange_date]
      @pt_trans.exchange_time = params[:transactions][:exchange_time]
      @pt_trans.exchange_note = params[:transactions][:exchange_note]

       # Save Address
      if params[:addresses].present?
        @my_address = Address.find_by_id(@pt_trans.address_id)
        if !@my_address.present?
          @my_address = Address.new(params[:addresses])
          @my_address.user_id = current_user.id
          @my_address.email = current_user.email
          @my_address.save
          @pt_trans.address_id = @my_address.id  
        else
          @my_address.update_attributes(params[:addresses])
          @my_address.save
        end
      end
      @pt_trans.save

      if @trade.transactions.where("user_id=#{current_user.id}").present?
        @my_exchange_method = @trade.transactions.where("user_id=#{current_user.id}").first.exchange_method
      end
      if @trade.item.user == current_user
        if @trade.transactions.where("user_id=#{@trade.offer.user.id}").present?
          @trader_exchange_method = @trade.transactions.where("user_id=#{@trade.offer.user.id}").first.exchange_method
        end
      else
        if @trade.transactions.where("user_id=#{@trade.item.user.id}").present?
          @trader_exchange_method = @trade.transactions.where("user_id=#{@trade.item.user.id}").first.exchange_method
        end
      end
    end

    # respond_to do |format|
    #   if @transaction.save
    #     format.html { redirect_to @transaction, notice: 'Transaction was successfully created.' }
    #     format.json { render json: @transaction, status: :created, location: @transaction }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @transaction.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PUT /transactions/1
  # PUT /transactions/1.json
  def update
     #debugger
    @transaction = Transaction.find(params[:id])
    params[:transaction][:ship_type_name] = params[:shipping].split(',')[0]
    params[:transaction][:ship_charge] = (params[:shipping].split(',')[1]).to_f
    params[:transaction][:ship_type_code] = params[:shipping].split(',')[2]

    @trade = Trade.find(@transaction.trade_id)
    @oth_transaction = @trade.transactions.where(user_id: @trade.offer.user_id).first
    #debugger
    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        # format.html { redirect_to @transaction, notice: 'Transaction was successfully updated.' }
        format.js
        format.json { head :ok } 
      else
        format.html { render action: "edit" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_address
    # debugger
    @my_transaction = Transaction.find(params[:id])
    @address = @my_transaction.address

    # params[:transaction][:ship_type_name] = params[:shipping].split(',')[0]
    # params[:transaction][:ship_charge] = (params[:shipping].split(',')[1]).to_f
    # params[:transaction][:ship_type_code] = params[:shipping].split(',')[2]
    respond_to do |format|
      if @address.update_attributes(:name => params[:name], :address_line_1 => params[:address_line1], :address_line_2 => params[:address_line2], :city => params[:city], :zipcode => params[:zipcode], :phone => params[:phone], :email => params[:email])
        # format.html { redirect_to @transaction, notice: 'Transaction was successfully updated.' }
        format.js
        format.json { head :ok } 
      else
        format.html { render action: "edit" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def trade_review
    # debugger
    @my_transaction = Transaction.find(params[:id])
   @trade = Trade.find(@my_transaction.trade_id)
    @oth_transaction = @trade.transactions.where(user_id: @trade.offer.user_id).first
    @card_id = params[:cardtype]
    respond_to do |format|
      format.js
    end
  end


  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    transaction = Transaction.find(params[:id])
    transaction.destroy
    respond_to do |format|
      format.html { redirect_to current_user_path } 
    end

  end
  
  def get_shipping
    
    @trade = Trade.find(params[:trade_id])
    #debugger
    packages = [
                Package.new( params[:weight].to_f * 16,                        # lbs, times 16 oz/lb
                            [params[:length].to_f, params[:width].to_f, params[:height].to_f],
                            :units => :imperial)                       # not grams, not centimetres
                
               ]
    # debugger
    if @trade.item.user_id == current_user.id
      @my_transaction = @trade.transactions.where(user_id: @trade.item.user_id ).first
      @oth_transaction = @trade.transactions.where(user_id: @trade.offer.user_id).first
      #debugger
    else
      @my_transaction = @trade.transactions.where(user_id: @trade.offer.user_id).first
      @oth_transaction = @trade.transactions.where(user_id: @trade.item.user_id ).first
      # debugger
    end
    #origin and destination for fetching ups_rates)
    origin = Location.new(:country => @my_transaction.address.country,
                          :state => @my_transaction.address.state,
                          :city => @my_transaction.address.city,
                          :zip => @my_transaction.address.zipcode)

    destination = Location.new(:country => @oth_transaction.address.country,
                               :state => @oth_transaction.address.state,
                               :city => @oth_transaction.address.city,
                               :zip => @oth_transaction.address.zipcode)
    # TODO: Call the Api and send back option
    # debugger
    @ups = UPS.new(:login => ENV['UPS_LOGIN'], :password => ENV['UPS_PASSWORD'], :key => ENV['UPS_KEY'])
    response = @ups.find_rates(origin, destination, packages)

    # getting rates, service types and service codes
    @ups_rates = response.rates.sort_by(&:price).collect {|rate| {:service_name => rate.service_name, 
                                                                  :price => (rate.price.to_f)/100, 
                                                                  :service_code => rate.service_code}}.to_json
    
    # ups_array =[]
    # response.rates.sort_by(&:price).each do |u|
    #   hash = {:service_name => u.service_name, :price => u.price, :service_code => u.service_code} 
    #   ups_array.push(hash)
    #   end
    # debugger  
    # @ups_service = response.rates.sort_by(&:price).collect {|rate| [rate.service_name]}
    # @ups_servicecode = response.rates.sort_by(&:price).collect {|rate| [rate.service_code]}
    # @ups_price = response.rates.sort_by(&:price).collect {|rate| [rate.price]}



    # jsonvalues = []
    # @ups_rates.each do |u| 
    #             {:} 
    # debugger

    # queue the job to get the labels asynchronously
    Resque.enqueue(GetTransactionLabelJob, @my_transaction.id, @oth_transaction.id)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @ups_rates }
    end    
  end

  # sample method for attaching a file to the model
  def attach_labels
    @transaction = Transaction.find(params[:id])
    file = File.open(file_path)
    @transaction.attachment = file
    file.close
    @transaction.save!
  end

  def make_trade
    # debugger
    @my_transaction = Transaction.find(params[:trans_id])
    @charge_card = ChargeCard.find(params[:card_id])
    
    charge = Stripe::Charge.create(
      :customer    => @charge_card.cust_id,
      :amount      => params[:cost_total].to_i,
      :card        => @charge_card.card_id,
      :description => 'Payment for trade',
      :currency    => 'usd'
    )
    
    @my_transaction.charge_id = charge.id
    @my_transaction.card_id = @charge_card.card_id
    @my_transaction.transaction_status = true
    @my_transaction.save!
    @trade = Trade.find(@my_transaction.trade_id)
    @trade.item.reduce_quantity
    @oth_transaction = @trade.transactions.where(user_id: @trade.offer.user_id).first
    if @oth_transaction.transaction_status == true
      @trade.status = 'COMPLETED'
      @trade.save!
    end
    redirect_to past_trades_user_path(@my_transaction.user_id)
  end


end
