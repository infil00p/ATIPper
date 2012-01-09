require 'test_helper'

class AgenciesControllerTest < ActionController::TestCase
  setup do
    @agency = agencies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:agencies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create agency" do
    assert_difference('Agency.count') do
      post :create, :agency => @agency.attributes
    end

    assert_redirected_to agency_path(assigns(:agency))
  end

  test "should show agency" do
    get :show, :id => @agency.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @agency.to_param
    assert_response :success
  end

  test "should update agency" do
    put :update, :id => @agency.to_param, :agency => @agency.attributes
    assert_redirected_to agency_path(assigns(:agency))
  end

  test "should destroy agency" do
    assert_difference('Agency.count', -1) do
      delete :destroy, :id => @agency.to_param
    end

    assert_redirected_to agencies_path
  end
end
