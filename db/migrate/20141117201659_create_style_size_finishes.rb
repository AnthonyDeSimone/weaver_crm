class CreateStyleSizeFinishes < ActiveRecord::Migration
  def change
    create_table :style_size_finishes do |t|
      t.string      :size
      t.string      :feature
      t.timestamps
    end
  end
end
