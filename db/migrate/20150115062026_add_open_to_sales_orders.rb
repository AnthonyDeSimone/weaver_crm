class AddOpenToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :open, :boolean, default: true
  end
end
