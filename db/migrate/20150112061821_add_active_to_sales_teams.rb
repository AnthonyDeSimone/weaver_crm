class AddActiveToSalesTeams < ActiveRecord::Migration
  def change
    add_column :sales_teams, :active, :boolean, default: true
  end
end
