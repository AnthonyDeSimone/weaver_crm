class AddApprovedToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :approved, :boolean
  end
end
