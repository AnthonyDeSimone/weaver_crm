class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :fishbowl_ip
      t.string :fishbowl_port
      
      t.timestamps
    end
  end
end
