object false
node (:success) {true}
node (:info) {'ok'}
child :data do
  node (:items_count) {@items.size}
  child @items do |item|
    attributes :id, :title, :created_at, :desc, :item_image, :quantity, :category_id

    node :distance do |x|
      x.user.user_distance(@user_ll)
    end

    child :user do
      attributes :id, :title, :user_image, :location
    end

    child :item_photos do
      attributes :id, :photo_file_name, :height, :width
    end
  end
end
