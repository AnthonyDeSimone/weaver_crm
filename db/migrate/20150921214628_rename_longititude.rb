class RenameLongititude < ActiveRecord::Migration
  def change
    rename_column :service_tickets, :longtitude, :longitude
  end
end
