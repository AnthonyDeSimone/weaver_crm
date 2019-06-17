class AddLockedFields < ActiveRecord::Migration
  def change
    add_column :sales_orders, :locked_by_id, :integer
    add_column :sales_orders, :locked_at, :datetime 
  end
end
