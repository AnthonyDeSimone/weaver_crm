class CreateSalesTeams < ActiveRecord::Migration
  def change
    create_table :sales_teams do |t|
      t.string      :name
      
      t.timestamps
    end
  end
end
