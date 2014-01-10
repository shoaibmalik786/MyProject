object false
node (:success) {true}
node (:info) {'ok'}
child :data do
  child @user do
    attributes :id, :title, :user_image, :location, :verifications
    node(:rating){@overall_rating}

    # child :comments do
    #   attributes :comment, :created_at
    #   node :user do |x|
    #     x.user.first_name + " " + x.user.last_name
    #   end
    # end
  end
end
