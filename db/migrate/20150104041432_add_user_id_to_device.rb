class AddUserIdToDevice < ActiveRecord::Migration
  def change
    add_reference :devices, :user, index: true
    add_foreign_key :devices, :users
  end
end
