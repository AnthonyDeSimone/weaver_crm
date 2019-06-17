class AddOutstandingSpecialOrderItems < ActiveRecord::Migration
  def change
    add_column :sales_orders, :outstanding_special_order, :integer, default: 0
  end
end
