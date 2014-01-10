class SuggestedCategory < ActiveRecord::Base

	def self.add_suggestion(suggestion, parent_id,user_id)
		if self.valid_suggestion(suggestion,parent_id,user_id)
			self.create(:parent_category_id => parent_id, :user_id => user_id, :suggested_category => suggestion)
			self.accept_suggestion(suggestion,parent_id)
		end
	end

	def self.valid_suggestion(suggestion,parent_id,user_id)
		suggestion = suggestion.gsub("\'","\\\\'")
		exist = self.find(:first, :conditions => "parent_category_id = #{parent_id} and user_id = #{user_id} and suggested_category = '#{suggestion}'")
		if exist.nil? 
			return true
		else 
			return false
		end
	end

	def self.accept_suggestion(suggestion,parent_id)
		suggestion = suggestion.gsub("\'","\\\\'")
		count = self.count(:all, :conditions => "parent_category_id = #{parent_id} and suggested_category = '#{suggestion}'")
		if count > 5
			Category.create(:name => suggestion, :category_id => parent_id)
			ActiveRecord::Base.connection.execute("UPDATE suggested_categories SET selected = true WHERE parent_category_id = #{parent_id} and suggested_category = '#{suggestion}'")
		end
	end

end

