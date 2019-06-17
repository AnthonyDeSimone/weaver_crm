class AddFinalizedDateToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :finalized_date, :datetime
  end
end
