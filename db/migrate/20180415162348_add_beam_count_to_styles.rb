class AddBeamCountToStyles < ActiveRecord::Migration
  def change
    add_column :styles, :beam_count, :integer
  end
end
