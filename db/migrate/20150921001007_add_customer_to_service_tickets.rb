class AddCustomerToServiceTickets < ActiveRecord::Migration
  def change
    add_reference :service_tickets, :customer
  end
end
