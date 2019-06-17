class AddPavillionBooleanToStyles < ActiveRecord::Migration
  def change
    add_column :styles, :pavillion, :boolean, default: false
  end
end
