class AddSidewallHeight < ActiveRecord::Migration
  def change
    add_column :structure_style_keys, :starting_sidewall_height, :integer
  end
end
