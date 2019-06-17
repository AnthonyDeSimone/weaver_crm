class AddBuildTypeToComponents < ActiveRecord::Migration
  def change
    add_column :components, :build_type, :integer, default: 0
  end
end
