class AddDoNotCompareToStyles < ActiveRecord::Migration
  def change
    add_column :styles, :do_not_compare, :boolean, default: false
  end
end
