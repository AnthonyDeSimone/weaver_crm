class AddApprovalToChangeOrders < ActiveRecord::Migration
  def change
    add_column :change_orders, :approved_1, :boolean, default: false
    add_column :change_orders, :approved_2, :boolean, default: false  
  end
end
