class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :name
      t.string :beacon_id
      t.string :device_type

      t.timestamps null: false
    end
  end
end
