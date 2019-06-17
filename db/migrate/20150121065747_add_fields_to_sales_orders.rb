class AddFieldsToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :estimated_time, :string
    add_column :sales_orders, :confirmed, :boolean, default: false
  end
end
