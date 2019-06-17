class AddExportedToChangeOrders < ActiveRecord::Migration
  def change
    add_column :change_orders, :exported, :boolean, default: false
  end
end
