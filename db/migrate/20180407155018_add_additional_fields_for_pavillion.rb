class AddAdditionalFieldsForPavillion < ActiveRecord::Migration
  def change
    add_column :style_keys, :post_amount, :integer
    add_column :style_keys, :beam_height, :integer
  end
end
