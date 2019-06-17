class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string      :name
      t.string      :address
      t.string      :city
      t.string      :county
      t.string      :state
      t.string      :zip
      t.string      :primary_phone
      t.string      :secondary_phone
      t.string      :zip
      t.integer     :lead_status
      t.string      :email

      t.datetime    :quote_date
      t.timestamps
    end
  end
end
