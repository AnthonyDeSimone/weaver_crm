class AddOrderIdToComponentsAndOptions < ActiveRecord::Migration
  def change
    add_column :components, :order_id, :integer
    add_column :component_options, :order_id, :integer
  end
end
