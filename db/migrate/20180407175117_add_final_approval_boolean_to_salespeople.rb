class AddFinalApprovalBooleanToSalespeople < ActiveRecord::Migration
  def change
    add_column :salespeople, :can_approve_orders, :boolean, default: false
  end
end
