class AddBuildStatusToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :build_status, :integer, default: 0
  end
end
