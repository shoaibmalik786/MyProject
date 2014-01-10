object false
node (:success) { true }
node (:info) { @want_status }
child :data do
  child @item do
    attributes :id
    node :total_wants do
         @wants_count
     end
  end
end
