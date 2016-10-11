require 'rails_helper'

describe Chat do
  subject(:chat) { create(:chat) }
  subject(:user) { create(:user) }

  describe '#join' do
    it 'should add a chat user' do
      chat.join(user)
      expect(chat.users).to include(user)
    end

    it 'should broadcast' do
      expect(ChatChannel).to(
        receive(:broadcast_to)
          .with(chat, event: :user_joined, user: user))

      chat.join(user)
    end

    context 'with joined user' do
      before do
        chat.chat_users.create(user: user)
      end

      it 'should not broadcast when already joined' do
        expect(ChatChannel).not_to receive(:broadcast_to)
        chat.join(user)
      end
    end
  end

  describe '#leave' do
    context 'with joined user' do
      before do
        chat.chat_users.create(user: user)
      end

      it 'should remove the chat user' do
        chat.leave(user)
        expect(chat.users).not_to include(user)
      end

      it 'should broadcast' do
        expect(ChatChannel).to(
          receive(:broadcast_to)
            .with(chat, event: :user_left, user: user))

        chat.leave(user)
      end
    end

    it 'should not broadcast when already left' do
      expect(ChatChannel).not_to receive(:broadcast_to)
      chat.leave(user)
    end
  end

  describe '#toggle_online' do
    context 'with offline user' do
      before do
        chat.chat_users.create(user: user, online: false)
      end

      it 'should put the user online' do
        chat.toggle_online(user, true)
        expect(chat.chat_users.find_by(user_id: user.id)).to be_online
      end

      it 'should broadcast the event' do
        expect(ChatChannel).to(
          receive(:broadcast_to)
            .with(chat, event: :user_online, user: user))

        chat.toggle_online(user, true)
      end

      it 'should not broadcast when already offline' do
        expect(ChatChannel).not_to receive(:broadcast_to)
        chat.toggle_online(user, false)
      end
    end

    context 'with online user' do
      before do
        chat.chat_users.create(user: user, online: true)
      end

      it 'should put the user offline' do
        chat.toggle_online(user, false)
        expect(chat.chat_users.find_by(user_id: user.id)).not_to be_online
      end

      it 'should broadcast the event' do
        expect(ChatChannel).to(
          receive(:broadcast_to)
            .with(chat, event: :user_offline, user: user))

        chat.toggle_online(user, false)
      end

      it 'should not broadcast when already online' do
        expect(ChatChannel).not_to receive(:broadcast_to)
        chat.toggle_online(user, true)
      end
    end
  end

  describe '#send_message' do
    it 'should add the message' do
      chat.send_message(user, 'test')

      message = chat.messages.last
      expect(message.text).to eq('test')
      expect(message.user).to eq(user)
    end

    it 'should broadcast the event' do
      expect(ChatChannel).to receive(:broadcast_to) do |obj, options|
        expect(obj).to eq(chat)
        expect(options[:event]).to eq(:message_sent)
        expect(options[:message]).to be_a(Message)
        expect(options[:message].text).to eq('test')
        expect(options[:message].user).to eq(user)
      end

      chat.send_message(user, 'test')
    end
  end
end
