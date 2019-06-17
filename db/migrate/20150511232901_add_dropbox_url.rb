class AddDropboxUrl < ActiveRecord::Migration
  def change
    add_column :sales_orders, :dropbox_url, :string
  end
end
