class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.string      :name
      t.string      :pricing_type #each, sq_ft, ln_ft, percentage
      t.decimal     :small_price
      t.decimal     :large_price
      t.string      :creator_image_path
      t.text        :options
      t.boolean     :requires_quantity
      t.string      :form_type
      t.string      :image_url


      t.belongs_to  :component_subcategory
      t.belongs_to  :style_key
      t.timestamps
    end
  end
end
