class CreateSalesmen < ActiveRecord::Migration
  def change
    create_table :salesmen do |t|
      t.timestamps
    end
  end
end
