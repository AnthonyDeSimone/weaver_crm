class AddNewImageFields < ActiveRecord::Migration
  def change
    add_column :components, :image_data, :text
    add_column :components, :image_content_type, :string

    add_column :component_options, :image_data, :text
    add_column :component_options, :image_content_type, :string    
  end
end
