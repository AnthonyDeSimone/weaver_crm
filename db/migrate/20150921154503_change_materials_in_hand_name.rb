class ChangeMaterialsInHandName < ActiveRecord::Migration
  def change
    rename_column :service_tickets, :materials_in_hand, :materials_not_in_hand
  end
end
