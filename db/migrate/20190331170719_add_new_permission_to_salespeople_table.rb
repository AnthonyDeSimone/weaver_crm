class AddNewPermissionToSalespeopleTable < ActiveRecord::Migration
  def change
    add_column :salespeople, :can_download_production_copy, :boolean, default: false
  end
end
