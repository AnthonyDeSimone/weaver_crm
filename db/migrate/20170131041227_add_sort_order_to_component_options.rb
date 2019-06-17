class AddSortOrderToComponentOptions < ActiveRecord::Migration
  def change
    add_column :component_options, :sort_order, :integer, default: 0
  end
end
