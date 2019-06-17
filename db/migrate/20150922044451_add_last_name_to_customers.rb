class AddLastNameToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :first_name, :string
    add_column :customers, :last, :string
  end
end
