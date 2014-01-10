class ReviewsController < ApplicationController

  cache_sweeper :review_sweeper, :only => [:create, :flagReview]

  def new
    if params[:token] and params[:token].present?
      @trade = Trade.find_by_single_review_token(params[:token])
      if @trade and !@trade.nil?
        if current_user and !current_user.nil?
          if @trade.offer.user.id != current_user.id
            sign_out current_user
            session[:review_token] = params[:token]
            redirect_to("/?add_review=true") and return
            # sign_in @trade.offer.user
          end
        else
          sign_in @trade.offer.user
        end
        @review = Review.new
      else
        redirect_to("/") and return
      end
    else
      redirect_to("/") and return
    end
  end

  def create
    # if params[:token] and params[:token].present?
      # if (@trade = Trade.find_by_single_review_token(params[:token]))
      review = Review.new(params[:review])
      acceptedOffer = AcceptedOffer.find_by_id params[:review][:accepted_offer_id]
      
      if acceptedOffer then trade = acceptedOffer.trade end
      
      if trade and trade.item.user_id == current_user.id
        review.reviewee_id = trade.offer.user_id
      elsif trade and trade.offer.user_id == current_user.id
        review.reviewee_id = trade.item.user_id
      else
      end
      
      if review.reviewee_id.present?
        @review = review
        @review.overall_rating = ((@review.describe_rating.to_f + @review.communication_rating.to_f)/2).ceil
        @review.reviewer_id = current_user.id
        @review.save

        other_users_review = Review.where("accepted_offer_id = " + @review.accepted_offer_id.to_s + " and reviewer_id = " + @review.reviewee_id.to_s)
        # Send email if reviewer submits a review and reviewee has not already submitted a review on same trade.
        if other_users_review.present?
          if @review.reviewer_id == acceptedOffer.trade.item.user_id
            TradeMailer.review_reminder_reviewer(acceptedOffer.trade.offer_id,acceptedOffer.trade.offer.user_id,acceptedOffer.trade.item_id,acceptedOffer.trade.item.user_id).deliver
          else
            TradeMailer.review_reminder_reviewer(acceptedOffer.trade.item_id,acceptedOffer.trade.item.user_id,acceptedOffer.trade.offer_id,acceptedOffer.trade.offer.user_id).deliver
          end
        else
          if @review.reviewer_id == acceptedOffer.trade.item.user_id
            TradeMailer.review_reminder_other_user(acceptedOffer.trade.item_id,acceptedOffer.trade.item.user_id,acceptedOffer.trade.offer_id,acceptedOffer.trade.offer.user_id).deliver
          else
            TradeMailer.review_reminder_other_user(acceptedOffer.trade.offer_id,acceptedOffer.trade.offer.user_id,acceptedOffer.trade.item_id,acceptedOffer.trade.item.user_id).deliver
          end
        end
      end
      
      @user = current_user
      @unreview_trades = @user.unreview_trades
      @user_reviews = @user.user_reviews.all(:order => "overall_rating desc")
      @reviews_of_user = @user.reviews.all(:order => "overall_rating desc")
      
      respond_to do |format|
        format.js
      end
      # redirect_to :back
        # if @review.save
        #   # @trade.update_attribute("single_review_token",nil)
        #   # session[:review_submitted] = true
        #   redirect_to :back
        # else
        #   render :action => "new"
        # end
      # else
        # redirect_to("/") and return
      # end
    # else
    #   redirect_to :back
    # end
  end

# requests and unrequest remove review
  def flagReview
    if params[:id]
      review = Review.find_by_id(params[:id])
      if review
        review.request_remove_flag = !review.request_remove_flag
        review.save
      end
    end
  end

end
