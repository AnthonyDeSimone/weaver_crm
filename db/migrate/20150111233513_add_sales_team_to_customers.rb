class AddSalesTeamToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :sales_team_id, :integer
    add_index :customers, :sales_team_id  
  end
end
