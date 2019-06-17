class Fixing < ActiveRecord::Migration
  def change
    remove_column :structure_style_keys, :starting_sidewall_height  
    add_column :style_keys, :starting_sidewall_height, :integer  
  end
end
