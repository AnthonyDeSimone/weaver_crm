class CreateComponentCategories < ActiveRecord::Migration
  def change
    create_table :component_categories do |t|
      t.string :name
      t.timestamps
    end
  end
end
