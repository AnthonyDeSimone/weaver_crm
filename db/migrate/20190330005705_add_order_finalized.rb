class AddOrderFinalized < ActiveRecord::Migration
  def change
    add_column :sales_orders, :finalized, :boolean, default: false
  end
end
