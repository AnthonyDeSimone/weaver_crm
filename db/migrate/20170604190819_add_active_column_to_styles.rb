class AddActiveColumnToStyles < ActiveRecord::Migration
  def change
    add_column :styles, :active, :boolean, default: true
  end
end
