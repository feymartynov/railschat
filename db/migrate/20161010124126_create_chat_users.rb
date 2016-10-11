class CreateChatUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :chat_users do |t|
      t.references :chat, null: false
      t.references :user, null: false
      t.boolean :online, null: false, default: false
      t.timestamps
    end

    add_index :chat_users, %i(chat_id user_id), unique: true
  end
end
