class AddLoginToFishbowlSettings < ActiveRecord::Migration
  def change
    add_column :settings, :fishbowl_username, :string
    add_column :settings, :fishbowl_password, :string
  end
end
