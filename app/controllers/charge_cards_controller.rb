class ChargeCardsController < ApplicationController
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!

# def index 
#     customer = Stripe::Customer.create(
#                                      :email => current_user.email,
#                                      :card  => params[:stripeToken]
#                                      )
#     cards = Stripe::Customer.retrieve(customer.id).cards.all

#     render :status => 200,
#            :json => { :success => true,
#                       :cards => cards
#                     }
# end

def index 
    charge_cards = ChargeCard.where(:user_id => current_user.id)

    render :status => 200,
           :json => { :success => true,
                      :cards => charge_cards
                    }
end


def create
    # Amount in cents

  # @amount = params[:amount]
  @user = current_user
  @my_transaction = Transaction.find(params[:transid])
  customer = nil
  card = nil
  if !@user.charge_cards.exists?
    customer = Stripe::Customer.create(
                                     :email => current_user.email,
                                     :card  => params[:stripeToken]
                                    )
    card = Stripe::Customer.retrieve(customer.id).cards.all(count: 1).first
  else
    
    customer_id = @user.charge_cards.last.cust_id
    customer = Stripe::Customer.retrieve(customer_id)
    
    card = customer.cards.create(:card  => params[:stripeToken])
    # charge_card = ChargeCard.where(:user_id => current_user.id)
    # clear_current(charge_card)
   
    
  end
    current_user.charge_cards.create(cust_id: customer.id,
                                   card_id: card.id,
                                   last_4: card.last4,
                                   provider: "stripe",
                                   exp_month: card.exp_month,
                                   exp_year: card.exp_year, 
                                   card_type: card.type,
                                   current: true
                                  )
  flash[:success] = "Your Charge card has been successfully added!"
  # debugger
  respond_to do |format|
    format.js # { render :layout => "false" } 
    format.json { render :json =>  { :success => true }} 
  end

  # charge = Stripe::Charge.create(
  #                                :customer    => customer.id,
  #                                :amount      => @amount,
  #                                :description => 'Rails Stripe customer',
  #                                :currency    => 'usd'
  #                               )
rescue Stripe::CardError => e
  flash[:error] = e.message
  redirect_to charge_card_charges_path
end

def destroy
  @user = current_user
  card = ChargeCard.find(params[:id])
  customer_id = card.cust_id
  debugger
  Stripe::Customer.retrieve(customer_id).cards.retrieve(card.card_id).delete()

  card.destroy
  respond_to do |format|
    format.js # { render :layout => "false" } 
    format.json { head :ok } 
  end
end
  #redirect_to edit_user_path(current_user.id)
#   else
#   format.html {redirect_to edit_user_path(current_user.id), notice: 'Card not deleted'}  



# def destroy
#   charge = ChargeCard.find_by_id(params[:card_id])
  
#   if charge.current
#     charge_current = ChargeCard.where(:user_id => current_user.id).first
#     charge_current.current = true
#     charge_current.save!
#   end
#   charge.destroy

#   render :status => 200,
#          :json => { :success => success,
#                     :data => {} }
# end

def clear_current(current)
  unless current.nil?
    current_card = ChargeCard.where(:user_id => current_user.id, :current => true)
    current_card.each do | card |
      card.current = false
      card.save
    end
  end
end

end
