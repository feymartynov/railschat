class CreateChats < ActiveRecord::Migration[5.0]
  def change
    create_table :chats do |t|
      t.string :name, null: false
      t.references :creator, references: :user
      t.timestamps
    end

    add_index :chats, :name, unique: true
  end
end
