require 'test_helper'

class PicsControllerTest < ActionController::TestCase
  setup do
    @pic = pics(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pics)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pic" do
    assert_difference('Pic.count') do
      post :create, pic: { base_64: @pic.base_64, device_id: @pic.device_id }
    end

    assert_redirected_to pic_path(assigns(:pic))
  end

  test "should show pic" do
    get :show, id: @pic
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @pic
    assert_response :success
  end

  test "should update pic" do
    patch :update, id: @pic, pic: { base_64: @pic.base_64, device_id: @pic.device_id }
    assert_redirected_to pic_path(assigns(:pic))
  end

  test "should destroy pic" do
    assert_difference('Pic.count', -1) do
      delete :destroy, id: @pic
    end

    assert_redirected_to pics_path
  end
end
