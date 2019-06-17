class ChangeMatertialsInHandColumn < ActiveRecord::Migration
  def change
    remove_column :service_tickets, :materials_not_in_hand
    add_column :service_tickets, :materials_not_in_hand, :integer
  end
end
