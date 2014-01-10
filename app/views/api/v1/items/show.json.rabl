object false
node (:success) {true}
node (:info) {'ok'}
child :data do
  child @item do
    attributes :id, :title, :created_at, :desc, :item_image, :condition,
    :delivery, :delivery_desc, :bring_it_to_you, :come_and_get_it, :lets_meet_up,
    :come_to_you, :come_to_me, :done_remotely, :ship_it, :lets_meet_service, :quantity,
    :category_id

    # node :shipping do
    #   attributes :delivery, :delivery_desc, :bring_it_to_you, :come_and_get_it, :lets_meet_up,
    #   :come_to_you, :come_to_me, :done_remotely, :ship_it, :lets_meet_service
    # end

    child :user do
      attributes :id, :title, :user_image, :location
    end

    node :likes_count do |x|
      x.likes.count
    end

    child :comments do
      attributes :comment, :created_at, :unless => lambda { |x| x.nil?}
      child :user do
        attributes :title, :user_image
      end
    end

    child :item_photos do
      attributes :id, :photo_file_name, :height, :width
    end

    if user_signed_in?
      node :logged_in_user do
        {
          :liked_status => @like_status,
          :wanted_status => @want_status,
          :has_status => @has_status
        }
      end
    end


  end
end
