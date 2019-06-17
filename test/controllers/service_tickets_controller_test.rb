require 'test_helper'

class ServiceTicketsControllerTest < ActionController::TestCase
  setup do
    @service_ticket = service_tickets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:service_tickets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create service_ticket" do
    assert_difference('ServiceTicket.count') do
      post :create, service_ticket: {  }
    end

    assert_redirected_to service_ticket_path(assigns(:service_ticket))
  end

  test "should show service_ticket" do
    get :show, id: @service_ticket
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @service_ticket
    assert_response :success
  end

  test "should update service_ticket" do
    patch :update, id: @service_ticket, service_ticket: {  }
    assert_redirected_to service_ticket_path(assigns(:service_ticket))
  end

  test "should destroy service_ticket" do
    assert_difference('ServiceTicket.count', -1) do
      delete :destroy, id: @service_ticket
    end

    assert_redirected_to service_tickets_path
  end
end
