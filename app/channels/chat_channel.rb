class ChatChannel < ApplicationCable::Channel
  def subscribed
    @chat = Chat.find_by!(name: params['chat_name'])
    stream_for @chat
    @chat.toggle_online(current_user, true)
  end

  def unsubscribed
    @chat.toggle_online(current_user, false)
  end

  def send_message(data)
    @chat.send_message(current_user, data['message'])
  end
end
