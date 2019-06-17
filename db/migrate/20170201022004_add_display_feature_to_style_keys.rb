class AddDisplayFeatureToStyleKeys < ActiveRecord::Migration
  def change
    add_column :style_keys, :display_feature, :string
  end
end
