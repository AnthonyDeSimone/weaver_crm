class AddMinimumRoofPitch < ActiveRecord::Migration
  def change
    add_column :style_keys, :minimum_roof_pitch, :integer
  end
end
