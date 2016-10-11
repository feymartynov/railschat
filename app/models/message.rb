class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chat

  validates :chat, presence: true
  validates :user, presence: true
  validates :text, presence: true

  def as_json(*_)
    { text: text, created_at: created_at, user: user }
  end
end
