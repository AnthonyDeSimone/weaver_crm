class AddLatitudeAndLongitudeToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :latitude,  :string
    add_column :sales_orders, :longitude, :string
  end
end
