class CreateSpecialOrderItems < ActiveRecord::Migration
  def change
    create_table :special_order_items do |t|
      t.string    :name
      t.string    :po_number
      t.string    :notes
      t.string    :part_type
      t.boolean   :required, default: false
      t.boolean   :ordered, default: false
      t.references  :sales_order
      t.timestamps
    end
  end
end
