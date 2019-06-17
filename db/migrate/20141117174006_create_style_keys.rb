class CreateStyleKeys < ActiveRecord::Migration
  def change
    create_table :style_keys do |t|
			t.integer		  :width
			t.integer		  :length
			t.integer	  	:sq_feet
			t.integer	  	:ln_feet
			t.integer	  	:starting_roof_pitch
			t.string	  	:feature
			t.text		  	:zone_prices    
			t.text		  	:door_defaults

      t.belongs_to  :style
      t.belongs_to  :style_size_finish
      t.timestamps
    end
  end
end
