require 'test_helper'

class TradeCommunicationsControllerTest < ActionController::TestCase
  setup do
    @trade_communication = trade_communications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trade_communications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trade_communication" do
    assert_difference('TradeCommunication.count') do
      post :create, trade_communication: {  }
    end

    assert_redirected_to trade_communication_path(assigns(:trade_communication))
  end

  test "should show trade_communication" do
    get :show, id: @trade_communication
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @trade_communication
    assert_response :success
  end

  test "should update trade_communication" do
    put :update, id: @trade_communication, trade_communication: {  }
    assert_redirected_to trade_communication_path(assigns(:trade_communication))
  end

  test "should destroy trade_communication" do
    assert_difference('TradeCommunication.count', -1) do
      delete :destroy, id: @trade_communication
    end

    assert_redirected_to trade_communications_path
  end
end
