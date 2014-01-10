class VerifyPhoneNumberController < ApplicationController
  skip_before_filter :verify_authenticity_token
  cache_sweeper :authentication_sweeper, :only => [:verify_phone_number_via_sms, :remove_verification]
  cache_sweeper :phone_number_sweeper, :only => [:verify_phone_number_via_sms, :remove_number_verification]

  def create
    pn = PhoneNumber.find(:first, :conditions => {:user_id => current_user.id, :phone_number => params[:phone_number]})

    if pn.nil? or (pn and not pn.verified)
      begin
        @client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN

        if pn.nil?
          pn = PhoneNumber.new({:user_id => current_user.id, :phone_number => params[:phone_number]})
          pn.save
        end
        @account = @client.account
        @account.calls.create to: pn.phone_number, from: YOUR_CALLER_ID, url: verify_phone_number_url(pn)

        render :text => pn.verification_code.to_s + ":" + pn.id.to_s
      rescue StandardError => e
        render :text => "CALL Failed"
      end
    else
      render :text => "Already verified!"
    end
  end

  def twilio_hack
    phone_number = PhoneNumber.find(params[:id]).tap do |v|
      v.user_input = params[:Digits]
      v.save
    end
    phone_number = PhoneNumber.find(params[:id])
    if phone_number.verified
      render :action => "verified.xml.builder", :layout => false
    else
      render :action => "verification_failed.xml.builder", :layout => false
    end
  end

  def show
    @pn = PhoneNumber.find(params[:id])
    @post_to = twilio_hack_verify_phone_number_url(@pn)
    render :action => "enter_verification_code.xml.builder", :layout => false
  end

  def twilio_call_verification_status
    pn = PhoneNumber.find(params[:id])
    if pn.verified
      render :text => "Success"
    else
      render :text => "Failed"
    end
  end

  def send_verification_code_via_sms
    if current_user
      pn = PhoneNumber.find(:first,
                            :conditions => {
                              :user_id => current_user.id,
                              :phone_number => params[:phone_number]}
                            )
    end
    if pn.nil? or (pn and not pn.verified)
      begin
        @client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN

        if pn.nil?
          pn = PhoneNumber.new({:user_id => current_user.id, :phone_number => params[:phone_number]})
          pn.save
        end

        msg = "TradeYa Verification Code: " + pn.verification_code.to_s
        @message = @client.account.sms.messages.create(
                                                       :From => YOUR_CALLER_ID,
                                                       :To => params[:phone_number],
                                                       :Body => msg
                                                       )
        puts @message
        render :text => "Sent"
      rescue
        render :text => "Failed"
      end
    else
      render :text => "Already"
    end
  end

  def verify_phone_number_via_sms
    if current_user.present?
      pn = PhoneNumber.find(:first,
                            :conditions => {
                              :user_id => current_user.id,
                              :phone_number => params[:phone_number]}
                            )
      pn.user_input = params[:verification_code]
      pn.save
    end

    if pn.present? and pn.verified
      render :text => "Verified"
    else
      render :text => "Failed"
    end
  end

  def remove_verification
    @authentication = current_user.authentication(params[:provider])
    if @authentication.provider == 'facebook'
      @authentication.verified = false
      @authentication.save
    else
      @authentication.destroy if @authentication
    end
    # User.update_friend_list(current_user.id,params[:provider])

    flash[:notice] = "Successfully destroyed authentication."
    # redirect_to edit_verifications_url
    render :text=> "success"
  end

  def remove_number_verification
    @phone_number = PhoneNumber.find_by_phone_number(params[:phone_number])
    @phone_number.destroy if @phone_number
    flash[:notice] = "Successfully destroyed authentication."
    render :text=> "success"
  end
end
