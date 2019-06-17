class AddExtraShippingFieldsToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :site_ready,      :boolean, default: false
    add_column :sales_orders, :working_on_site, :boolean, default: false
    add_column :sales_orders, :scheduled,       :boolean, default: false
    add_column :sales_orders, :load_complete,   :boolean, default: false
  end
end
