class AddActiveStatusToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :active, :boolean, default: true
  end
end
