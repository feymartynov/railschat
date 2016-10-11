class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :chat_users, dependent: :destroy
  has_many :chats, -> { order(:name) }, through: :chat_users

  validates :name, presence: true, uniqueness: true

  with_options if: -> { new_record? || changes[:crypted_password] } do
    validates :password, length: { minimum: 5 }, confirmation: true
    validates :password_confirmation, presence: true
  end

  def as_json(*_)
    { id: id, name: name }
  end
end
