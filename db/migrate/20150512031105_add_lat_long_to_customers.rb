class AddLatLongToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :latitude, :string
    add_column :customers, :longitude, :string
  end
end
