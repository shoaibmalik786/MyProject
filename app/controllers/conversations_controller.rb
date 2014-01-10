class ConversationsController < ApplicationController
  helper_method :mailbox, :conversation
  before_filter :authenticate_user!

  def fetchConversations
    return current_user.mailbox.conversations(:include => { :receipts => :notification }) - current_user.mailbox.trash(:include => { :receipts => :notification })
  end

  def show   
    
    @conv = Conversation.find(params[:id], :include => {:receipts => :notification })
    if !@conv.is_read?(current_user)
      @conv.mark_as_read(current_user)
    end

    # fetch participants from the method
    @participants = fetchParticipants
    if @conv.is_completely_trashed?(current_user)
      @convs = current_user.mailbox.trash(:include => { :receipts => :notification })
    else
      # @convs = current_user.mailbox.conversations(:mailbox_type => 'not_trash',:include => { :receipts => :notification })
      # @convs = current_user.mailbox.conversations(:include => { :receipts => :notification }) - current_user.mailbox.trash(:include => { :receipts => :notification })
      @convs = fetchConversations
    end
    # @convs = @convs.sort_by! {|c| (c.receipts(current_user).where('mailbox_type != ? and receiver_id = ?','trash',current_user.id).last.created_at)}.reverse

    respond_to do |format|
      format.js
    end
  end

  def markasunread
    conversation = Conversation.find(params[:conv_id])
    conversation.mark_as_unread(current_user)
    @convs = fetchConversations
    respond_to do |format|
      format.js
    end
  end

  def markasread
    conversation = Conversation.find(params[:conv_id])
    conversation.mark_as_read(current_user)
    @convs = fetchConversations
    respond_to do |format|
      format.js
    end
  end

  def reply
    # @convs = @convs.sort_by! {|c| (c.receipts(current_user).where('mailbox_type = ? and receiver_id = ?','inbox',current_user.id).last.created_at)}.reverse
    @replyAction = false
    @newMessage = false
    @flash = false
    @trash = false

    # if a reply is being sent to a conversation
    if params[:reply_message]
      @replyAction = true
      body = params[:body]
     
      subject = nil
        
      if params[:body] == ""
        body = "dummybody_text"
      end
      if (params[:body] == nil or params[:body] == "") and params[:attach] == nil
        @flash = true
        flash[:alert] = "Body must be specified."
      # elsif params[:attach] != nil and params[:photo].size > 5.megabytes
      #   @flash = true
      #   flash[:alert] = "File size cannot be greater than 5MB."
      else
        
        # receipt = current_user.reply_to_conversation(conversation, body, subject, true, true, params[:photo])
        receipt = current_user.reply_to_conversation(conversation, body, subject, true, true, nil)

        if params[:attach] != nil
          # attachmentsAll = params[:attach] 
          # attachmentsAll = attachmentsAll - attachmentsAll[0]
          params[:attach].each do |attachment|
            attachmentToSave = AttachmentMessaging.new
            attachmentToSave.notif_id = receipt.notification.id
            attachmentToSave.attachment = attachment
            attachmentToSave.save
          end
        end

        # untrash in case the conversation has been deleted by the the other users
        participants = conversation.participants 
        if participants.count >= 2 
          blacklist = [current_user] 
          participants = participants - blacklist
        end
        participants.each do |participant|
          participant.mailbox.receipts_for(conversation).untrash
        end
      end
      @conv = conversation
      @participants = fetchParticipants

    # if new message is created
    elsif params[:new_message]
      rec_emails = params[:recipients]
      rec_user = User.where(email: rec_emails).all
       @body_for_text = params[:body]
       @subject_for_text = params[:subject]
       @rec_for_text = params[:recipients]
      if rec_emails == nil or rec_emails == []
        @flash = true
        flash[:alert] = "Atleast one user must be specified."
      elsif params[:subject] == nil or params[:subject] == ""
        @flash = true
        flash[:alert] = "Subject must be specified."
      elsif params[:body] == nil or params[:body] == ""
        @flash = true
        flash[:alert] = "Body must be specified."
      else
        conversation = current_user.send_message(rec_user, params[:body], params[:subject], true, nil).conversation
        receipt = conversation.receipts_for(current_user)
        if params[:attach] != nil
          params[:attach].each do |attachment|
            attachmentToSave = AttachmentMessaging.new
            attachmentToSave.notif_id = receipt[0].notification.id
            attachmentToSave.attachment = attachment
            attachmentToSave.save
          end
        end
        
      end 
      @newMessage = true
      # when messages are to be deleted
    elsif params[:delete_selected]
      
      receiptsSelected = params[:chk_rec]
      convForDelRec = Receipt.find(receiptsSelected[0]).conversation
      receiptsSelected.each do |rec|
        receiptToBeDeleted = Receipt.find(rec)
        # receiptToBeDeleted.update_column(:deleted, true) 
        receiptToBeDeleted.destroy  

      end
      if convForDelRec.receipts_for(current_user).count == 0
          @newMessage = true
      else
        @conv = convForDelRec
        # call fetchparticipants method
        @participants = fetchParticipants
        @trash = true  
      end
      # @convs = current_user.mailbox.conversations(:mailbox_type => 'not_trash',:include => { :receipts => :notification })
    end
    @convs = fetchConversations
    # @convs = current_user.mailbox.conversations(:include => { :receipts => :notification }) - current_user.mailbox.trash(:include => { :receipts => :notification })
    # @convs = current_user.mailbox.conversations(:mailbox_type => 'not_trash',:include => { :receipts => :notification })
    # @convs = @convs.sort_by! {|c| (c.receipts(current_user).where('mailbox_type != ? and receiver_id = ?', 'trash', current_user.id).last.created_at)}.reverse
    respond_to do |format|
      format.js
    end
  end

  # custom method to fetch participants in a conversation
  def fetchParticipants
    participants = @conv.participants 
      if participants.count >= 2 
        blacklist = [current_user] 
        participants = participants - blacklist
    end
    return participants
  end

  # method to display inbox
  def displayinbox
    # @convs = current_user.mailbox.conversations(:mailbox_type => 'not_trash',:include => { :receipts => :notification })
    @convs = fetchConversations
    # @convs = current_user.mailbox.conversations(:include => { :receipts => :notification }) - current_user.mailbox.trash(:include => { :receipts => :notification })
    respond_to do |format|
      format.js
    end
  end

  # method to display new message
  def newmsg
    @convs = fetchConversations
    respond_to do |format|
      format.js
    end
  end

  # send to trash, the complete conversation
  def trash
    conversationToBeArchived = Conversation.find(params[:conv_id])
    conversationToBeArchived.move_to_trash(current_user)
    # @convs = current_user.mailbox.conversations(:mailbox_type => 'not_trash',:include => { :receipts => :notification })
    @convs = fetchConversations
    # @convs = current_user.mailbox.conversations(:include => { :receipts => :notification }) - current_user.mailbox.trash(:include => { :receipts => :notification })
    respond_to do |format|
      format.js
    end
  end

  # move a trashed conversation back to inbox
  def untrash
    conversationToBeUntrashed = Conversation.find(params[:conv_id])
    conversationToBeUntrashed.untrash(current_user)
    @convs = current_user.mailbox.trash(:include => { :receipts => :notification })
    respond_to do |format|
      format.js
    end
  end

  # permanently delete, the complete conversation
  def delete
    conversationToBeDeleted = Conversation.find(params[:conv_id])
    receiptsToBeDel = conversationToBeDeleted.receipts_for(current_user)
    receiptsToBeDel.each do |rec|
      rec.update_column(:deleted, true)
    end
    @convs = current_user.mailbox.trash(:include => { :receipts => :notification })
    respond_to do |format|
      format.js
    end
  end

  # to download attached file
  def download
    file = AttachmentMessaging.find(params[:att_id]).attachment.path
    send_file( file )
    # file = Notification.find(params[:notif_id]).attachment.file.path
    # send_file( file )
  end

  # method to display trash messages
  def displaytrash
    @convs = current_user.mailbox.trash(:include => { :receipts => :notification })
    # @trashconvs = @convs.sort_by! {|c| (c.receipts(current_user).where('mailbox_type = ? and receiver_id = ?','trash',current_user.id).last.created_at)}.reverse
    respond_to do |format|
      format.js
    end
    
  end

	# to append a conversation based on the id
  def conversation
    
      @conversation ||= mailbox.conversations.find(params[:id])
    end

    # fetched the current user mailbox. Provided by the gem
  def mailbox
    @mailbox ||= current_user.mailbox
  end

  # breaks the parameters and passes on to fetch_params function to fetch 
  # a result based on the parameters passed.
  def conversation_params(*keys)
      fetch_params(:conversation, *keys)
    end

    # breaks the parameters and passes on to fetch_params function to fetch 
  # a result based on the parameters passed.
    def message_params(*keys)
      fetch_params(:message, *keys)
    end

    # fetches a result based on the parameters passed. 
    def fetch_params(key, *subkeys)
      params[key].instance_eval do
      case subkeys.size
      when 0 then self
      when 1 then self[subkeys.first]
      else subkeys.map{|k| self[k] }
      end
    end
  end
end
