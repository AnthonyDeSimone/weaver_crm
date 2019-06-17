class AddInfusionsoftIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :infusionsoft_id, :integer
  end
end
