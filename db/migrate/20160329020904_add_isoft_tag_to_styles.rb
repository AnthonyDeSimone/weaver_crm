class AddIsoftTagToStyles < ActiveRecord::Migration
  def change
    add_column :styles, :isoft_tag_id, :integer
  end
end
