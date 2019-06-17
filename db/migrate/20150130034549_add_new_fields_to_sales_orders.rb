class AddNewFieldsToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :ship_address, :string
    add_column :sales_orders, :ship_city, :string
    add_column :sales_orders, :ship_state, :string
    add_column :sales_orders, :ship_zip, :string
    add_column :sales_orders, :ship_county, :string

    add_column :sales_orders, :notes, :text
  end
end
