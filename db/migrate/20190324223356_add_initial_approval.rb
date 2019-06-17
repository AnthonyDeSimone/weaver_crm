class AddInitialApproval < ActiveRecord::Migration
  def change
    add_column :sales_orders, :initial_approval, :boolean, default: false 
  end
end
