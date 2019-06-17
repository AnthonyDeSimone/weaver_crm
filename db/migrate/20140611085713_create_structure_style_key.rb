class CreateStructureStyleKey < ActiveRecord::Migration
  def change
    create_table :structure_style_keys do |t|
			t.string		:style
			t.integer		:width
			t.integer		:length
			t.integer		:sq_feet
			t.integer		:ln_feet
			t.string		:feature
			t.integer		:starting_roof_pitch
			t.text			:zone_prices    
			t.text			:door_defaults
		
			t.timestamps 
		end
  end
end


