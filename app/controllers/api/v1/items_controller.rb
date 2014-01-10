class Api::V1::ItemsController < ApplicationController
  skip_before_filter :verify_authenticity_token,
  :if => Proc.new { |c| c.request.format == 'application/json' }

  before_filter :authenticate_user_from_token!, :except => [:index, :show, :search]
  respond_to :json

  def index
    # @items = Item.last(10)
    # @user_ll = [34.0126379,-118.495155]
    radius = params[:radius] ||= 25
    search = params[:search]
    page_size = params[:page_size] ||= 10
    page = params[:page]
    sort = params[:sort]
    cat = params[:category_id]
    condition = params[:condition]
    delivery = params[:delivery]
    @user_ll = []
    unless params[:lat].nil? || params[:lng].nil?
      @user_ll << params[:lat]
      @user_ll << params[:lng]
    end
    @items  = Item.item_search(search, cat, sort, condition, delivery, page,
                               @user_ll, radius, page_size)
    @items.nil? ? @items = [] : @items &&= @items.results

  end

  def create
    @item = current_user.items.build(params[:item])
    @item.status = "LIVE"
    if @item.save
      item_photos = params[:photos]
      if item_photos && item_photos.count > 0
        item_photos.each do |p|
          photo = ItemPhoto.new(:photo => p)
          photo.item_id = @item.id
          photo.save
        end
      end
    else
      render :status => :unprocessable_entity,
      :json => {
        :success => false,
        :info => @item.errors,
        :data => {}
      }
    end
  end

  def show
    @item = Item.find_by_id(params[:id])
    if @item
      if current_user.present?
        @like_status = current_user.has_liked?(@item)
        @want_status = current_user.wants_item?(@item)
        @has_status = current_user.has_item?(@item)
      end
    else
      render :status => :unprocessable_entity,
      :json => {
        :success => false,
        :info => @item.errors,
        :data => {}
      }
    end
  end

  def like
    @item = Item.find_by_id(params[:id])
    @like_status =""
    like_data = Like.find_by_item_id_and_user_id(params[:id],current_user.id)
    if params[:like] == "true"
      if like_data.blank?
        Like.create(:item_id => params[:id],:user_id => current_user.id )
        @like_status = "Liked!"
      end
    elsif like_data
      like_data.destroy
      @like_status = "Un-Liked!"
    end
    @like_count = @item.like.count
  end

  def wants
    @item = Item.find_by_id(params[:id])
    @want_status = ""
    wants_data = Want.find_by_item_id_and_user_id(params[:id],current_user.id)
    if params[:wants] == "true"
      if wants_data.blank?
        Want.create(:item_id => params[:id],:user_id => current_user.id )
        @want_status = "Wanted!"
      end
    elsif wants_data
      wants_data.destroy
      @want_status = "Unwanted"
    end
    @wants_count = @item.wants.count
  end

  def haves
    @item = Item.find_by_id(params[:id])
    @haves_status =""
    haves_data = Have.find_by_item_id_and_user_id(params[:id],current_user.id)
    if params[:haves] == "true"
      if haves_data.blank?
        Have.create(:item_id => params[:id],:user_id => current_user.id )
        @have_status = "Items added to haves board!"
      end
    elsif haves_data
      haves_data.destroy
      @have_status = "Item removed from haves board."
    end
    @haves_count = @item.haves.count
  end

  def comment
    @item = Item.find_by_id(params[:id])
    @comment = Comment.new(:comment => params[:comment])
    @comment.user_id = current_user.id
    @comment.item_id = params[:id]
    if @comment.save
      render :status => 200,
      :json => { :success => true,
        :info => "Comment successfully added!",
        :data => {} }

    else
      render :status => :unprocessable_entity,
      :json => {
        :success => false,
        :info => @comment.errors,
        :data => {}
      }
    end
  end

  def search
# if !params[:dict].present?
#       @items = Item.last(10)
#     else
#       @items = Item.search(params[:dict][:search])
#     end
 end

end
