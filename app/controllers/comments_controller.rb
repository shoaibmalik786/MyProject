class CommentsController < ApplicationController
  before_filter :current_location
  # before_filter :require_user, :only => [:create]
  before_filter :authenticate_user!, :only => [:create]
  cache_sweeper :comment_sweeper, :only => [:create, :update, :destroy]

  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.includes(:replies).all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.json
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.json
  #TODO need refactoring as per change
  def create
    if current_user
      @item = Item.find(params[:id])
      
      if current_user.wants.pluck(:item_id).include? @item.id
        $redis.srem("recent-items:#{current_user.id}", "wants:#{@item.id}")
        $redis.sadd("recent-items:#{current_user.id}", "wants:#{@item.id}")
        @members = $redis.smembers("recent-items:#{current_user.id}")
        if @members.size > 5
          $redis.srem("recent-items:#{current_user.id}", $redis.smembers("recent-items:#{current_user.id}").last)
        end
      end

      if params[:t] and params[:id]
        comment = Comment.new(params[:comment])
        comment.user_id = current_user.id
        comment.item_id = params[:id]
        comment.save
        # if comment.save

        @comments = @item.comments.active
        # else
        #   @comments = Comment.item_comments(comment.item_id)
        #   @item = Item.find(comment.item_id)
        # end
        respond_to do |format|
          format.js
          format.html { redirect_to user_path(@item.user)}
        end
      elsif params[:id]
        comment = Comment.new(params[:comment])
        comment.user_id = current_user.id
        comment.item_id = params[:id]
        item = Item.find(params[:id])
        if comment.save
          # alert = Alert.find_by_sender_id_and_receiver_id_and_alert_type(current_user.id,item.user.id,ALERT_TYPE_COMMENT)
          # if alert.present?
          #   alert.update_alert(alert.id)
          # else
          #   Alert.create_alert(current_user.id,item.user.id,ALERT_TYPE_COMMENT,item.id)
          # end
          if comment.offer_id.present?
            @trade = Trade.find(comment.offer_id)
            @status = @item.item_status
            @pub = ((@item.user_id == current_user.id)? true : false)
          else
            @comments = Comment.item_comments(comment.item_id)
          end

          if @item.user != current_user
            #Send email to item's owner if comment received on item
            if (InfoAndSetting.sm_on_comment_by_other and @item.user.notify_received_comments)
              ItemMailer.comment_received(@item.id,comment.user_id).deliver 
              # Activity Feed
              comment.create_activity key: @item.id, owner: comment.user, recipient: @item.user
            end
          else
            #Send email to other commenters if owner replies to their comment
            item_commenters = @item.comments.where('deleted = false').pluck(:user_id).uniq
            other_commenters = item_commenters.delete_if{|x| x == @item.user.id.to_i} #exclude item user
            other_commenters.each do |other_commenter|
              other_commenter_user = User.find(other_commenter)
              if (InfoAndSetting.sm_on_comment_by_other and other_commenter_user.notify_received_comments)
                ItemMailer.reply_comment_received(@item.id,comment.user_id,comment.id,other_commenter).deliver
              end
            end
          end


          if current_user.id != @item.user_id
            # Alert.add_2_alert_q(ALERT_TYPE_TRADEYA, NEW_COMMENT_ON_TRADEYA_4_PUB, @item.user.id, @item.id)
            
            # if InfoAndSetting.sm_on_comment_by_other then EventNotificationMailer.see_comment(@item, current_user,comment).deliver end
            if InfoAndSetting.sm_on_comment_by_other and comment.item.user.notify_received_comments then EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_SEE_COMMENT, comment.item.user.id, {:comment_id => comment.id}) end
          else
            if InfoAndSetting.sm_on_comment_by_pub
              if comment.offer_id.present?
                user = @trade.offer.user
                # Alert.add_2_alert_q(ALERT_TYPE_OFFER, NEW_COMMENT_ON_TRADEYA_4_OFFERER, user.id, comment.item_id)
                EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_SEE_PUB_COMMENT, user.id, {:comment_id => comment.id}) if user.notify_received_comments
              else
                sent_ids = []
                @comments.each do |c|
                  # @item.trades.each do |c|
                  if c.user_id != current_user.id and sent_ids.index(c.user_id).nil?
                    # Alert.add_2_alert_q(ALERT_TYPE_OFFER, NEW_COMMENT_ON_TRADEYA_4_OFFERER, c.user_id, @item.id)

                    # EventNotificationMailer.see_pub_comment(@item, c.offer.user).deliver
                    # EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_SEE_PUB_COMMENT, c.offer.user.id, {:trade_id => c.id})
                    EventNotification.add_2_notification_q(NOTIFICATION_TYPE_USER_SETTING, NOTIFICATION_SEE_PUB_COMMENT, c.user_id, {:comment_id => comment.id}) if c.user.notify_received_comments
                    sent_ids[sent_ids.count] = c.user_id
                  end
                end
              end
            end
          end
        else
          @comments = Comment.item_comments(comment.item_id)
          @item = Item.find(comment.item_id)
        end
        if !@item.nil?
          @status = @item.item_status
        end
        respond_to do |format|
          format.js {render :action => "create"}
          format.html { redirect_to item_path(@item)}
        end
      end
      # render :layout => false

    end
  end

  def reply
    if params.present?
      @comment = Comment.find(params[:comment_id]) if params[:comment_id]
      reply = Comment.new(item_id: params[:item_id], user_id: current_user.id,comment: params[:reply],parent_comment_id: params[:comment_id])
      respond_to do |format|
        if reply.save!
          format.js {render action: 'reply'}
        end
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.json
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    if current_user
      @comment = Comment.find(params[:id])
      item_id = @comment.item_id
      @comment.deleted = true
      @comment.save

      respond_to do |format|
        @item = Item.find(item_id)
        @status = @item.item_status
        if @comment.offer_id.present?
          @trade = Trade.find(@comment.offer_id)
          @pub = ((@item.user_id == current_user.id)? true : false)
        else
          # @comments = Comment.item_comments(item_id)
          @comments = @item.comments.active
        end
        format.html { redirect_to comments_url }
        format.js
      end   
    end
  end
end
