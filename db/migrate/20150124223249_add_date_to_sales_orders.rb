class AddDateToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :date, :datetime
  end
end
