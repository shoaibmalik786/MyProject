object false
node (:success) { true }
node (:info) { 'Item created!' }
child :data do
  child @item do
    attributes :id, :title, :desc, :created_at, :item_image
  end
end