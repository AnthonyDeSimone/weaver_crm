class AddDisplayNameToStyles < ActiveRecord::Migration
  def change
    add_column :styles, :display_name, :string
    add_column :style_size_finishes, :display_feature, :string
    add_column :components, :active, :boolean, default: true
  end
end
