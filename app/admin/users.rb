ActiveAdmin.register User do

  # form do |f|
  #   f.inputs "User Details" do
  #     f.input :email
  #     f.input :password
  #     f.input :password_confirmation
  #     f.input :superadmin, :label => "Super Administrator"
  #   end
  #   f.buttons
  # end

  # create_or_edit = Proc.new {
  #   @user            = User.find_or_create_by_id(params[:id])
  #   @user.superadmin = params[:user][:superadmin]
  #   @user.attributes = params[:user].delete_if do |k, v|
  #     (k == "superadmin") ||
  #       (["password", "password_confirmation"].include?(k) && v.empty? && !@user.new_record?)
  #   end
  #   if @user.save
  #     redirect_to :action => :show, :id => @user.id
  #   else
  #     render active_admin_template((@user.new_record? ? 'new' : 'edit') + '.html.erb')
  #   end
  # }
  # member_action :create, :method => :post, &create_or_edit
  # member_action :update, :method => :put, &create_or_edit

  index do
    column :id
    # column "Photo" do |u|
    #   div do
    #     link_to(image_tag(u.user_image, :class => 'u_img'), edit_admin_user_path(u))
    #   end
    # end
    column "Email" do |u|
      div do
        mail_to(u.email)
      end
    end
    column "First Name", :first_name
    column "Last Name", :last_name
    column "City", :city
    column "State", :state
    # column "Zip", :zip
    # column "Can Delete Item", :can_delete_item
    column "Request Invite Date", :created_at

    default_actions
  end

end
