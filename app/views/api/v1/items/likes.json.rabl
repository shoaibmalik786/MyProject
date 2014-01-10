object false
node (:success) { true }
node (:info) { @like_status }
child :data do
  child @item do
    attributes :id
    node :total_likes do
      @like_count
    end
  end
end
