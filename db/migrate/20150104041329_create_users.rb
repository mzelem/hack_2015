class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :login
      t.string :password
      t.string :gateway_id
      t.string :auth_token
      t.string :request_token

      t.timestamps null: false
    end
  end
end
