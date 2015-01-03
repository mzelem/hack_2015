class CreateGuests < ActiveRecord::Migration
  def change
    create_table :guests do |t|
      t.string :name
      t.string :phone
      t.string :token
      t.datetime :check_in
      t.datetime :checkout
      t.string :bluetooth_id
      t.string :preferred_language

      t.timestamps null: false
    end
  end
end
