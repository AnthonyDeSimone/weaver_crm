class AddJsonInfoToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :json_info, :text 
  end
end
