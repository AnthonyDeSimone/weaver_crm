class AddSalespersonToChangeOrders < ActiveRecord::Migration
  def change
    add_reference :change_orders, :salesperson
  end
end
