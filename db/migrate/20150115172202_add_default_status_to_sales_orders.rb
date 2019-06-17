class AddDefaultStatusToSalesOrders < ActiveRecord::Migration
  def change
    change_column :sales_orders, :status, :integer, default: 0
  end
end
