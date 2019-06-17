class ModifyIssuedColumnOnSalesOrders < ActiveRecord::Migration
  def change
    change_column :sales_orders, :issued, :boolean, default: false
  end
end
