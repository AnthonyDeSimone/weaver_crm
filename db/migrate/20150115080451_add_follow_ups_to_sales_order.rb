class AddFollowUpsToSalesOrder < ActiveRecord::Migration
  def change
    add_column :sales_orders, :follow_ups, :integer, default: 0
  end
end
