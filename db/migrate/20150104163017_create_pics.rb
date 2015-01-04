class CreatePics < ActiveRecord::Migration
  def change
    create_table :pics do |t|
      t.belongs_to :device, index: true
      t.text :base_64

      t.timestamps null: false
    end
    add_foreign_key :pics, :devices
  end
end
