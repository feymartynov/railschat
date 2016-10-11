class Chat < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  has_many :chat_users, dependent: :destroy
  has_many :users, through: :chat_users
  has_many :messages, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :creator, presence: true

  def join(user)
    return if chat_users.find_by(user: user)
    chat_user = chat_users.create!(user: user, online: true)
    ChatChannel.broadcast_to(self, event: :user_joined, user: user)
    chat_user
  end

  def leave(user)
    chat_user = chat_users.find_by(user: user) || return
    chat_user.destroy
    ChatChannel.broadcast_to(self, event: :user_left, user: user)
  end

  def toggle_online(user, online)
    chat_user = chat_users.find_by!(user: user)
    return if chat_user.online == online

    chat_user.update_attributes!(online: online)
    event = online ? :user_online : :user_offline
    ChatChannel.broadcast_to(self, event: event, user: user)
    chat_user
  end

  def send_message(user, text)
    message = messages.create!(user: user, text: text)
    ChatChannel.broadcast_to(self, event: :message_sent, message: message)
    message
  end
end
