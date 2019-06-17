class AddLastContactDateToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :last_contact_date, :date
  end
end
