class AddHeightAndWidthToComponents < ActiveRecord::Migration
  def change
    add_column :components, :height, :integer
    add_column :components, :width, :integer
  end
end
