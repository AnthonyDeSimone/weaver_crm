class CreateKeyComponentPairs < ActiveRecord::Migration
  def change
    create_table :key_component_pairs do |t|
      t.belongs_to  :component
      t.belongs_to  :style_size_finish
      t.timestamps
    end
  end
end
