class CreateSalesOrders < ActiveRecord::Migration
  def change
    create_table :sales_orders do |t|
      t.decimal     :percent_discount
      t.decimal     :dollar_discount
      t.decimal     :delivery_charge
      t.decimal     :tax
      t.decimal     :deposit
      t.integer     :build_type
      t.boolean     :issued
      t.integer     :status
    
      t.datetime    :site_ready_date
      t.datetime    :delivery_date

      t.belongs_to  :salesperson  
      t.belongs_to  :customer
      t.belongs_to  :structure_style_key

      t.timestamps
    end
  end
end
