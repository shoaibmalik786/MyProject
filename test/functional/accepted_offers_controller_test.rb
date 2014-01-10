require 'test_helper'

class AcceptedOffersControllerTest < ActionController::TestCase
  setup do
    @accepted_offer = accepted_offers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:accepted_offers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create accepted_offer" do
    assert_difference('AcceptedOffer.count') do
      post :create, accepted_offer: @accepted_offer.attributes
    end

    assert_redirected_to accepted_offer_path(assigns(:accepted_offer))
  end

  test "should show accepted_offer" do
    get :show, id: @accepted_offer.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @accepted_offer.to_param
    assert_response :success
  end

  test "should update accepted_offer" do
    put :update, id: @accepted_offer.to_param, accepted_offer: @accepted_offer.attributes
    assert_redirected_to accepted_offer_path(assigns(:accepted_offer))
  end

  test "should destroy accepted_offer" do
    assert_difference('AcceptedOffer.count', -1) do
      delete :destroy, id: @accepted_offer.to_param
    end

    assert_redirected_to accepted_offers_path
  end
end
