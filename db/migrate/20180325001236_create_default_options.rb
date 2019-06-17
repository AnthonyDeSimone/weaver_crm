class CreateDefaultOptions < ActiveRecord::Migration
  def change
    create_table :default_options do |t|
      t.references  :component
      t.references  :component_option
      t.references  :style
      t.timestamps
    end
  end
end
