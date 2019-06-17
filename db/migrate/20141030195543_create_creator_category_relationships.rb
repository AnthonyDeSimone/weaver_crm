class CreateCreatorCategoryRelationships < ActiveRecord::Migration
  def change
    create_table :creator_category_relationships do |t|
      t.integer :parent_id
      t.integer :child_id      
    end
  end
end
