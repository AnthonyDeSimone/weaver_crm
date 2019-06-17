class AddImageStringToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :image_string, :text
  end
end
