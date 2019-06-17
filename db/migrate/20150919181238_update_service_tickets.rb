class UpdateServiceTickets < ActiveRecord::Migration
  def change
    rename_column :service_tickets, :details, :notes
    rename_column :service_tickets, :finished, :completed
    add_column :service_tickets, :info, :binary
    remove_column :service_tickets, :sales_order_id
    add_column :service_tickets, :site_visit_required, :boolean
    add_column :service_tickets, :time_frame, :integer
    add_column :service_tickets, :customer_presence_required, :boolean
    add_column :service_tickets, :materials_in_hand, :boolean
  end
end
