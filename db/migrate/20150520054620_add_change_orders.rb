class AddChangeOrders < ActiveRecord::Migration
  def change
    create_table :change_orders do |t|
      t.binary  :json_info
      t.binary  :revisions
      t.integer :sales_order_id
      t.binary  :image_string
      t.text    :prices
           
      t.timestamps
    end  
  end
end
