class CreateComponentOptions < ActiveRecord::Migration
  def change
    create_table :component_options do |t|
      t.string      :name
      t.decimal     :small_price
      t.decimal     :large_price
      t.string      :image_url


      t.belongs_to  :component
      t.timestamps
    end
  end
end
