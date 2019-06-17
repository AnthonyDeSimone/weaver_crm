class FixCustomerLastName < ActiveRecord::Migration
  def change
    rename_column :customers, :last, :last_name
  end
end
