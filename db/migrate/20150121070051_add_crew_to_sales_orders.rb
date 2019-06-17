class AddCrewToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :crew, :string
  end
end
