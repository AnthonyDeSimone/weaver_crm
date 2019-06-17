class AddAdditionalSalesTeamsToSalesPeople < ActiveRecord::Migration
  def change
    create_table :salespeople_sales_teams
    add_column :salespeople_sales_teams, :salesperson_id, :integer
    add_column :salespeople_sales_teams, :sales_team_id, :integer
  end
end
