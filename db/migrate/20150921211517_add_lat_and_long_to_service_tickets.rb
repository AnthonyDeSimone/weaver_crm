class AddLatAndLongToServiceTickets < ActiveRecord::Migration
  def change
    add_column :service_tickets, :latitude, :string
    add_column :service_tickets, :longtitude, :string
  end
end
