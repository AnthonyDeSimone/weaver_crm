class CreateCustomerComments < ActiveRecord::Migration
  def change
    create_table :customer_comments do |t|
      t.text        :comment

      t.belongs_to  :customer
      t.timestamps
    end
  end
end
