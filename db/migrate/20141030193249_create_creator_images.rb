class CreateCreatorImages < ActiveRecord::Migration
  def change
    create_table :creator_images do |t|
      t.string  :component
      t.string  :image_file

      t.timestamps
    end
  end
end
