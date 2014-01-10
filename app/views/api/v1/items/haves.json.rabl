object false
node (:success) { true }
node (:info) { @haves_status }
child :data do
  child @item do
    attributes :id
    node :total_likes do
      @haves_count
    end
  end
end
