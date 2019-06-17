class AddInfusionsoftBooleans < ActiveRecord::Migration
  def change
    add_column :salespeople, :track_in_infusionsoft, :boolean, default: false
    add_column :sales_teams, :track_in_infusionsoft, :boolean, default: false
  end
end
