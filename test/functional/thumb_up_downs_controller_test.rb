require 'test_helper'

class ThumbUpDownsControllerTest < ActionController::TestCase
  setup do
    @thumb_up_down = thumb_up_downs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:thumb_up_downs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create thumb_up_down" do
    assert_difference('ThumbUpDown.count') do
      post :create, thumb_up_down: @thumb_up_down.attributes
    end

    assert_redirected_to thumb_up_down_path(assigns(:thumb_up_down))
  end

  test "should show thumb_up_down" do
    get :show, id: @thumb_up_down.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @thumb_up_down.to_param
    assert_response :success
  end

  test "should update thumb_up_down" do
    put :update, id: @thumb_up_down.to_param, thumb_up_down: @thumb_up_down.attributes
    assert_redirected_to thumb_up_down_path(assigns(:thumb_up_down))
  end

  test "should destroy thumb_up_down" do
    assert_difference('ThumbUpDown.count', -1) do
      delete :destroy, id: @thumb_up_down.to_param
    end

    assert_redirected_to thumb_up_downs_path
  end
end
