class AddAosFinishPrice < ActiveRecord::Migration
  def change
    add_column :sales_orders, :aos_finish_price, :decimal, :precision => 6, :scale => 2
  end
end
