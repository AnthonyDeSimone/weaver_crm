class FixSalesOrdersTable < ActiveRecord::Migration
  def change
    drop_table :sales_orders
    
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
    
    add_column :sales_orders, :json_info, :binary 
    add_column :sales_orders, :finalized_date, :datetime       
    add_column :sales_orders, :prices, :text
    add_column :sales_orders, :open, :boolean, default: true
    change_column :sales_orders, :issued, :boolean, default: false
    add_column :sales_orders, :follow_ups, :integer, default: 0
    change_column :sales_orders, :status, :integer, default: 0
    add_column :sales_orders, :estimated_time, :string
    add_column :sales_orders, :confirmed, :boolean, default: false
    add_column :sales_orders, :crew, :string
    add_column :sales_orders, :date, :datetime
    add_column :sales_orders, :image_string, :binary                                          
  end
end
