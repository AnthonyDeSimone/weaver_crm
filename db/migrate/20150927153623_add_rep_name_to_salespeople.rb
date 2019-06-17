class AddRepNameToSalespeople < ActiveRecord::Migration
  def change
    add_column :salespeople, :rep_name, :string
  end
end
