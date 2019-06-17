class AddDimensionsToComponentOptions < ActiveRecord::Migration
  def change
    add_column :component_options, :height, :integer
    add_column :component_options, :width, :integer  
  end
end
