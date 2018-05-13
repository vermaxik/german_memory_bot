class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, force: true do |t|
      t.integer :uid
      t.string :login
      t.string :name
      t.datetime :created_at
    end
  end
end
