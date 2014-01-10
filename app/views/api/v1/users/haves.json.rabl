object false
node (:success) {true}
node (:info) {'ok'}
child :data do
  node (:items_count) {@have_items.size}
  child @have_items do |item|
    attributes :id, :title, :created_at, :desc, :item_image

    child :item_photos do
      attributes :id, :photo_file_name, :height, :width
    end
  end
end
