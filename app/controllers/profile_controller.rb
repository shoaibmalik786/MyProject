class ProfileController < ApplicationController
  before_filter :require_user,
  :only => [:index,:add_user_sub_cat, :get_suggested_categories, :suggest_new_category]

  #--------------------------------------------------------------------------#
  # index ----> "Returns the profile page"
  # Params --- IN:
  # nil
  # Params --- OUT:
  # +@goods_cat+:: Array of Hash objects, where each hash is a category in goods with data - id, name, imageURL, subcategories
  # +@services_catt+:: Array of Hash objects, where each hash is a category in services with data - id, name, imageURL, subcategories
  # +@interests_cat+:: Array of Hash objects, where each hash is a category in interests with data - id, name, imageURL, subcategories
  # +@show_get_started+:: boolean variable indicating if Get-Started model is to be shown or not, it is shown when user reaches profile page for the first time
  #--------------------------------------------------------------------------#
  def index
    @goods_cat = Category.goods_sub_categories
    @services_cat = Category.services_sub_categories
    @interests_cat = Category.interests_sub_categories
    @show_get_started = false
    @g_prvw_img = User.preview_item_match(current_user.goods_sub_cat_ids, 1,current_user.id)
    @s_prvw_img = User.preview_item_match(current_user.services_sub_cat_ids,2,current_user.id)
    @i_prvw_img = User.preview_person_match(current_user.interests_sub_cat_ids,3,current_user.id)
    if not current_user.showed_onboarding
      @show_get_started = true
      current_user.showed_onboarding = true
      current_user.onboarding_at = Time.zone.now
      current_user.save
    end
  end


  #--------------------------------------------------------------------------#
  # update_user_categories ----> "Updates user profile with selected categories and wish"
  # Params --- IN:
  # +step_1+:: sub-categories in goods selected by user
  # +step_2+:: sub-categories in services selected by user
  # +step_3+:: sub-categories in interests selected by user
  # +wish+:: wish entered by user
  # +update_queue+:: set user's existing matched-queue as invalid, as his preferences have changed
  # Params --- OUT:
  # nil
  #--------------------------------------------------------------------------#
  def update_user_categories
    if current_user
      if params["step_1"]
        current_user.goods_sub_cat_ids = params["step_1"]
      end
      if params["step_2"]
        current_user.services_sub_cat_ids = params["step_2"]
      end
      if params["step_3"]
        current_user.interests_sub_cat_ids = params["step_3"]
      end
      if params["wish"]
        current_user.wish = params["wish"]
      end
      # update_queue exits if profile is edited.
      if params["update_queue"]
        # set previous queue to invalid
        current_user.clear_prev_tradeya_match
        current_user.clear_prev_person_match
      end
      if current_user.save
        flash[:notice] = "User profile successfully updated"
        render :text => "success"
      else
        flash[:notice] = "Error in updating user profile"
        render :text => "error"
      end
    else
      flash[:notice] = "No current user found."
      render :text => "error"
    end
  end

  #--------------------------------------------------------------------------#
  # execute_matching ----> "Run matching algo, to get a Tradeya that matched user's preference"
  # Params --- IN:
  # +edit+::
  # Params --- OUT:
  # returns path of matched TradeYa, if match found, else returns the path of root
  #--------------------------------------------------------------------------#
  def execute_matching
    if current_user
      # current_user.person_match(true)
      matched_item = current_user.tradeya_match(true,true)
      if params[:edit]
        render :text => dashboard_url
        # redirect_to dashboard_url
      else
        # match_found = TradeyaMatchingResult.match_result(current_user)
        if matched_item.nil?
          render :text => root_url
          # redirect_to root_url
        else
          # match_id = match_found.match_result_q.split(',')[0]
          # match = Item.find(match_id)
          session[:match_found] = matched_item
          current_user.tradeya_match_ids = ((current_user.tradeya_match_ids.nil? or current_user.tradeya_match_ids.blank?) ? "#{matched_item.id}" : (current_user.tradeya_match_ids + ",#{matched_item.id}"))
          current_user.save
          render :text => item_path(matched_item)
          # redirect_to match.item_url
        end
      end
    else
      render :text => root_url
    end
  end


  #--------------------------------------------------------------------------#
  # suggest_new_category ----> "Add sub-category suggested by the user"
  # Params --- IN:
  # +suggestion+:: suggested sub-category
  # +parent_id+:: parent category ID
  # Params --- OUT:
  # nil
  #--------------------------------------------------------------------------#
  def suggest_new_category
    if params[:suggestion] and !params[:suggestion].blank?
      suggestion = params[:suggestion].split(' ').map {|w| w.capitalize }.join(' ')
      cat = Category.find_by_name(suggestion)
      if cat.nil?
        SuggestedCategory.add_suggestion(suggestion, params[:parent_id],current_user.id)
        render :text => "success"
      else
        render :text => "Category name already exists"
      end
    end
  end


  #--------------------------------------------------------------------------#
  # search_similar_categories ----> "Find similar sub-categories, to be shown in the dropdown"
  # Params --- IN:
  # +category_id+:: parent category ID
  # +value+:: value added by the user in the textbox
  # Params --- OUT:
  # Array of names of similar categories as a JSON object
  #--------------------------------------------------------------------------#
  def search_similar_categories
    items = []
    if params[:category_id] and !params[:category_id].blank? and params[:value] and !params[:value].blank?
      suggestions = SuggestedCategory.find(:all, :conditions => ["selected = false and parent_category_id = #{params[:category_id]} and suggested_category LIKE ?", "%#{params[:value]}%"], :group => "suggested_category")
      if !suggestions.nil? and suggestions.size > 0
        suggestions.each do |s|
          items[items.count] = view_context.escape_javascript(s.suggested_category)
        end
      end
    end
    render :text => items.to_json
  end

  def search_potential_match
    if current_user
      if !params[:step].blank? and !params[:sub_cat_ids].blank?
        step = params[:step].to_i
        sub_cat_ids = params[:sub_cat_ids]
        if (step == 1 or step == 2)
          match_img = User.preview_item_match(sub_cat_ids,step,current_user.id)
        else
          match_img = User.preview_person_match(sub_cat_ids,step,current_user.id)
        end
        render :text => match_img
      end
    else
      render :text => "error"
    end
  end

end
