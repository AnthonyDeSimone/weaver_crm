class AddOrderDateToOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :optional_order_date, :datetime
    add_column :sales_orders, :optional_quote_date, :datetime
  end
end
