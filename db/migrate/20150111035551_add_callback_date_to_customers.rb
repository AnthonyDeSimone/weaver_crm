class AddCallbackDateToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :callback_date, :datetime
  end
end
