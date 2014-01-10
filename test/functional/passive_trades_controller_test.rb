require 'test_helper'

class PassiveTradesControllerTest < ActionController::TestCase
  setup do
    @passive_trade = passive_trades(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:passive_trades)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create passive_trade" do
    assert_difference('PassiveTrade.count') do
      post :create, passive_trade: {  }
    end

    assert_redirected_to passive_trade_path(assigns(:passive_trade))
  end

  test "should show passive_trade" do
    get :show, id: @passive_trade
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @passive_trade
    assert_response :success
  end

  test "should update passive_trade" do
    put :update, id: @passive_trade, passive_trade: {  }
    assert_redirected_to passive_trade_path(assigns(:passive_trade))
  end

  test "should destroy passive_trade" do
    assert_difference('PassiveTrade.count', -1) do
      delete :destroy, id: @passive_trade
    end

    assert_redirected_to passive_trades_path
  end
end
