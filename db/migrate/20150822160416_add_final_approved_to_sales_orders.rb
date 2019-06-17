class AddFinalApprovedToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :approved_1, :boolean, default: false
    add_column :sales_orders, :approved_2, :boolean, default: false
  end
end
