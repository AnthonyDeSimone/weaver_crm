class AddSerialNumberToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :serial_number, :string, default: nil
  end
end
