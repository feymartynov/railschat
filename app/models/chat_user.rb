class ChatUser < ApplicationRecord
  belongs_to :chat
  belongs_to :user

  validates :chat, presence: true
  validates :user, presence: true

  def as_json(*_)
    { id: user_id, name: user.name, online: online }
  end
end