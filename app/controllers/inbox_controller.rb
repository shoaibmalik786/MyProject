class InboxController < ApplicationController
	require 'will_paginate/array'
  helper_method :mailbox
  before_filter :current_location
  before_filter :require_user, :only => [:show, :index, :haves, :likes, :wants, :following,
                                        :past_trades, :reviews, :myoffers, :inbox]
  def messaging
    if params[:id].present?
      if params[:send_to].present?
        @receiver = User.find(params[:send_to])
      end
      @user = User.find_by_id(params[:id])
      @user_images = @user.user_all_image(:medium)
      @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
      @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
      @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
      @convs = current_user.mailbox.conversations(:include => { :receipts => :notification }) - current_user.mailbox.trash(:include => { :receipts => :notification }) if current_user.present?
    end
  end

  def notifications
    if params[:id].present?
      @user = User.find_by_id(params[:id])
      @user_images = @user.user_all_image(:medium)
      @overall_rating = @user.overall_rating.round(1) if @user.overall_rating.present?
      @describe_rating = @user.describe_rating.round(1) if @user.describe_rating.present?
      @communication_rating = @user.communication_rating.round(1) if @user.communication_rating.present?
    
      @activity_feed = @user.activity_feed(params[:sort_by])#.paginate(:page => params[:page], :per_page => 5)
      
      @new_items_count = 0
      if @activity_feed.present?
        @activity_feed.each do |a|
          if (a.trackable_type == "Like" and ((a.recipient_id == current_user.id and !a.viewed_by_recipient) or (a.owner_id == current_user.id and !a.viewed_by_owner)))
            @new_items_count += 1
          elsif (a.trackable_type == "Comment" and a.recipient_id == current_user.id and !a.viewed_by_recipient)
            @new_items_count += 1
          elsif (a.trackable_type == "Item" and a.owner_id == current_user.id and !a.viewed_by_owner)
            @new_items_count += 1
          elsif (a.trackable_type == "Want" and ((a.recipient_id == current_user.id and !a.viewed_by_recipient) or (a.owner_id == current_user.id and !a.viewed_by_owner)))
            @new_items_count += 1
          end
        end
      end
    end
    # @convs = current_user.mailbox.conversations(:include => { :receipts => :notification }) - current_user.mailbox.trash(:include => { :receipts => :notification })

  end
end
