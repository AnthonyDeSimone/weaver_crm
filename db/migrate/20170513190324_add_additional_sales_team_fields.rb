class AddAdditionalSalesTeamFields < ActiveRecord::Migration
  def change
    add_column :sales_teams, :business_name, :string
    add_column :sales_teams, :address, :string
    add_column :sales_teams, :phone, :string
    add_column :sales_teams, :fax, :string
    add_column :sales_teams, :email, :string
    add_column :sales_teams, :show_company_on_invoice, :boolean, default: false
  end
end
