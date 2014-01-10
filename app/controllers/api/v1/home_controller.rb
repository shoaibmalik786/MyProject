class Api::V1::HomeController < ApplicationController
  skip_before_filter :check_route
  skip_before_filter :verify_authenticity_token,
  :if => Proc.new { |c| c.request.format == 'application/json' }

  before_filter :authenticate_user_from_token!, :except => [:categories]
  respond_to :json

  def categories
    @goods = Category.goods
    @services = Category.services
  end

end
