class AddActiveFlagToComponentOptions < ActiveRecord::Migration
  def change
    add_column :component_options, :active, :boolean, default: true
  end
end
