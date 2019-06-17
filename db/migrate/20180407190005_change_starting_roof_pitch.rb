class ChangeStartingRoofPitch < ActiveRecord::Migration
  def change
    change_column :style_keys, :starting_roof_pitch, :decimal, precision: 3, scale: 1
  end
end
