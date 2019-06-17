class AddSecondaryEmailToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :secondary_email, :string
  end
end
