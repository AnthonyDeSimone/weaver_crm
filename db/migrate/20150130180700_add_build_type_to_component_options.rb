class AddBuildTypeToComponentOptions < ActiveRecord::Migration
  def change
    add_column :component_options, :build_type, :integer, default: 0 
  end
end
