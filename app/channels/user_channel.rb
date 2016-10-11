class UserChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def get_chat_state(data)
    chat = Chat.includes(chat_users: :user).find_by!(name: data['chat_name'])

    UserChannel.broadcast_to(
      current_user,
      event: 'chat_state',
      users: chat.chat_users,
      messages: chat.messages.order(:created_at).limit(100))
  end
end
