class CreateCreatorCategories < ActiveRecord::Migration
  def change
    create_table :creator_categories do |t|
      t.belongs_to :creator_image
      t.timestamps
    end
  end
end
