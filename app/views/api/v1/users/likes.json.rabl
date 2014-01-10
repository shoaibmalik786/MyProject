object false
node (:success) {true}
node (:info) {'ok'}
child :data do
  node (:items_count) {@liked_items.size}
  child @liked_items do |item|
    attributes :id, :title, :created_at, :desc, :item_image

    node :distance do |x|
      x.user.user_distance(@user_ll)
    end

    child :user do
      attributes :title, :user_image, :location
    end

    child :item_photos do
      attributes :id, :photo_file_name, :height, :width
    end
  end
end
