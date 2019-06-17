class CreateSalesOrderItems < ActiveRecord::Migration
  def change
    create_table :sales_order_items do |t|
      t.integer     :quantity
      t.decimal     :price
      t.text        :description

      t.belongs_to  :component
      t.belongs_to  :component_option
      t.timestamps
    end
  end
end
