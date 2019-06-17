class AddSortOrderToStyles < ActiveRecord::Migration
  def change
    add_column :styles, :sort_order, :integer, default: 50
  end
end
