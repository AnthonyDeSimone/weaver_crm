class FinalizedInFishbowl < ActiveRecord::Migration
  def change
    add_column :sales_orders, :finalized_in_fishbowl, :boolean, default: false
  end
end
