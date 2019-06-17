class AddProductionPrintedDateToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :production_order_printed_at, :datetime
  end
end
