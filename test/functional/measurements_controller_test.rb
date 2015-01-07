require 'test_helper'

class MeasurementsControllerTest < ActionController::TestCase
  setup do
    @measurement = measurements(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:measurements)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create measurement" do
    assert_difference('Measurement.count') do
      post :create, measurement: @measurement.attributes.update(test: 'creative thinking')
      assert_no_errors :measurement
    end

    assert_redirected_to measurement_path(assigns(:measurement))
  end

  test "should not create duplicate measurement" do
    assert_no_difference('Measurement.count') do
      post :create, measurement: @measurement.attributes
      assert_no_errors :measurement
    end
    assert_redirected_to measurements_path
  end

  test "should show measurement" do
    get :show, id: @measurement.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @measurement.to_param
    assert_response :success
  end

  test "should update measurement" do
    put :update, :id => @measurement.to_param, :measurement => @measurement.attributes
    assert_redirected_to measurement_path(assigns(:measurement))
  end

  test "should destroy measurement" do
    assert_difference('Measurement.count', -1) do
      delete :destroy, :id => @measurement.to_param
    end

    assert_redirected_to measurements_path
  end
end
