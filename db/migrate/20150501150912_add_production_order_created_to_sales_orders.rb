class AddProductionOrderCreatedToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :production_order_created, :boolean, default: false
  end
end
