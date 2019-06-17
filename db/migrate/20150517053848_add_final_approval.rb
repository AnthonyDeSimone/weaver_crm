class AddFinalApproval < ActiveRecord::Migration
  def change
    add_column :sales_orders, :final_approval, :boolean, default: false
  end
end
