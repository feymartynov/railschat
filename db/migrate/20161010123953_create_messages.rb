class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.references :chat, null: false
      t.references :user, null: false
      t.string :text, null: false
      t.timestamp :created_at
    end

    add_index :messages, :created_at
  end
end
