class AddSpecialOrderItemsToSalesOrder < ActiveRecord::Migration
  def change
    add_column :sales_orders, :special_order_items, :binary
  end
end
