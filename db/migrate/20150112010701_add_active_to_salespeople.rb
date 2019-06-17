class AddActiveToSalespeople < ActiveRecord::Migration
  def change
    add_column :salespeople, :active, :boolean, default: true
  end
end
