class AddNameToSalespeople < ActiveRecord::Migration
  def change
    add_column :salespeople, :name, :string
  end
end
