class CreateServiceTickets < ActiveRecord::Migration
  def change
    create_table :service_tickets do |t|
      t.text        :details
      t.datetime    :date
      t.boolean     :confirmed, default: false
      t.boolean     :finished, default: false
      
      t.belongs_to  :sales_order
      t.belongs_to  :salesperson
      t.timestamps
    end
  end
end
