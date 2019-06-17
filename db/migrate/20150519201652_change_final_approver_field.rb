class ChangeFinalApproverField < ActiveRecord::Migration
  def change
    rename_column :sales_orders, :final_approver, :final_approver_id
  end
end
