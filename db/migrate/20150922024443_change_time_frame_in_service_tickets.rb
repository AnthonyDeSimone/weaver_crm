class ChangeTimeFrameInServiceTickets < ActiveRecord::Migration
  def change
    change_column :service_tickets, :time_frame, :string
  end
end
