class ChangeHeightWidthColumns < ActiveRecord::Migration
  def change
    change_column :components, :height, :decimal
    change_column :components, :width, :decimal

    change_column :component_options, :height, :decimal
    change_column :component_options, :width, :decimal
  end
end
