class AddSalesTeamToSalespeople < ActiveRecord::Migration
  def change
    add_column :salespeople, :sales_team_id, :integer
    add_index :salespeople, :sales_team_id
  end
end
