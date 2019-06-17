class AddLastModifiedToSalesOrder < ActiveRecord::Migration
  def change
    add_column :sales_orders, :modified_by_id, :integer
  end
end
