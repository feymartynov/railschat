class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :crypted_password, null: false
      t.string :salt, null: false
      t.timestamps
    end

    add_index :users, :name, unique: true
  end
end
