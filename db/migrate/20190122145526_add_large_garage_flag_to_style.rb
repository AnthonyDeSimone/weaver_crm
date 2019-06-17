class AddLargeGarageFlagToStyle < ActiveRecord::Migration
  def change
    add_column :styles, :large_garage, :boolean, default: false
  end
end
