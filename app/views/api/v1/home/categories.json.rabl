object false
node (:success) { true }
node (:info) { 'Category List!' }
child :data do
  child @goods => :goods do
    attributes :id, :name
  end

  child @services => :services do
    attributes :id, :name
  end
end
