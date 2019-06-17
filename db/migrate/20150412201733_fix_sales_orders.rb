class FixSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :in_fishbowl, :boolean, default: false      
  end
end
