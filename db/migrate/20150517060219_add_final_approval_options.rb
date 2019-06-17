class AddFinalApprovalOptions < ActiveRecord::Migration
  def change
    add_column :sales_orders, :final_approver, :integer
    add_column :sales_orders, :final_approval_time, :datetime
  end
end
