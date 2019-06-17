class AddPricesToSalesOrder < ActiveRecord::Migration
  def change
    add_column :sales_orders, :prices, :text
  end
end
