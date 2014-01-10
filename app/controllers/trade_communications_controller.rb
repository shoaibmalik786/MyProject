class TradeCommunicationsController < InheritedResources::Base
	
	def create
		if params[:trade_communications].present?
			tc = TradeCommunication.new(params[:trade_communications])
			tc.owner_id = current_user.id

			if params[:trade_communications][:passive_trade_id].present?
				# Passive Trade
				@passive_trade = PassiveTrade.find_by_id(params[:trade_communications][:passive_trade_id])
      	@trade_comments = @passive_trade.trade_comments
      	@trade_terms = @passive_trade.trade_terms
				tc.recipient_id = params[:trade_communications][:recipient_id]
			elsif params[:trade_communications][:trade_id].present?
				# Trade
				@trade = Trade.find_by_id(params[:trade_communications][:trade_id])
      	@trade_comments = @trade.trade_comments
      	@trade_terms = @trade.trade_terms
      	if @trade.item.user == current_user
					tc.recipient_id = @trade.offer.user.id
				else
					tc.recipient_id = @trade.item.user.id
				end
			end
			tc.save
		end
	end

	def destroy
		if params[:id].present?
			tt = TradeCommunication.find(params[:id])
			tt.deleted = true
			tt.save

			if params[:passive_trade_id].present?
				# Passive Trade
				@passive_trade = PassiveTrade.find_by_id(params[:passive_trade_id])
	    	@trade_comments = @passive_trade.trade_comments
	    	@trade_terms = @passive_trade.trade_terms
			elsif params[:trade_id].present?
				# Trade
				@trade = Trade.find_by_id(params[:trade_id])
	      @trade_comments = @trade.trade_comments
	      @trade_terms = @trade.trade_terms
			end
		end
	end

end
