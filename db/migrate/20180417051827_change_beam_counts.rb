class ChangeBeamCounts < ActiveRecord::Migration
  def change
    remove_column :styles, :beam_count
    #add_column :style_keys, :beam_counts, :integer
  end
end
