class ModifyJoinsTable < ActiveRecord::Migration
  def change
    drop_table :salespeople_sales_teams
    
    create_table :sales_team_connectors do |t|
      t.belongs_to :salesperson, index: true
      t.belongs_to :sales_team, index: true
    end
  end
end
