module ConversationsHelper
	# method to check if a conversation is deleted or not
	def is_deleted?(conv,user)
		receipts = conv.receipts_for(user)
		bAllDel = true
		receipts.each do |rec|
			if !rec.deleted?
				bAllDel = false
			end
		end
		return bAllDel
	end
end
