class AddReferralFieldsToSalesOrder < ActiveRecord::Migration
  def change
    add_column :sales_orders, :sales_method,    :string
    add_column :sales_orders, :advertisement,   :string
    add_column :sales_orders, :exported,        :boolean, default: false
  end
end
                      
