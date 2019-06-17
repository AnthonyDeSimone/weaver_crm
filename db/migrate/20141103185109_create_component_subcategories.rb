class CreateComponentSubcategories < ActiveRecord::Migration
  def change
    create_table :component_subcategories do |t|
      t.string :name
      t.belongs_to  :component_category
      t.timestamps
    end
  end
end
