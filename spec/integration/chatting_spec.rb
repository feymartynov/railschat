require 'rails_helper'

feature 'Chatting' do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given(:chat) { create(:chat) }
  given(:other_chat) { create(:chat) }

  scenario 'Creating a new chat' do
    login_user(user)
    visit '/'

    within('#new_chat') do
      fill_in 'Input chat name', with: 'test'
      click_button 'Join'
    end

    expect(page).to have_content '#test'
  end

  context 'with chat' do
    def login(user)
      visit '/login'

      within('#new_session') do
        fill_in 'Name', with: user.name
        fill_in 'Password', with: 'secret'
        click_button 'Log in'
      end

      expect(page).to have_content 'Logged in as'
    end

    scenario 'Joining an existing chat', :js do
      login(user)
      chat = create(:chat, :with_messages)
      visit '/'

      within('#new_chat') do
        fill_in 'Input chat name', with: chat.name
        click_button 'Join'
      end

      expect(page).to have_content "#{chat.name}"

      message = chat.messages.first
      time = message.created_at.strftime('%H:%M:%S')
      expected_text = "[#{time}] @#{message.user.name}: #{message.text}"
      expect(page.find('#messages')).to have_content(expected_text)

      expect(page.find('#users_list')).to have_content("@#{message.user.name}")
      expect(page.find('#users_list')).to have_content("@#{user.name}")
    end

    scenario 'Sending a message', :js do
      # two users go to the same chat
      [user, other_user].each do |current_user|
        in_browser(current_user) do
          login(current_user)
          visit "/chats/#{chat.name}"
        end
      end

      # the first user sends a message
      in_browser(user) do
        within('#message_form') do
          find(:css, 'input[name=message]').set('hello world')
          click_button 'Send'
        end
      end

      # both users should see this message
      expected_text = "@#{user.name}: hello world"

      [user, other_user].each do |current_user|
        in_browser(current_user) do
          expect(page.find('#messages')).to have_content(expected_text)
        end
      end
    end

    scenario 'Tracking users online status', :js do
      RSpec::Matchers.define :have_online_state do |online|
        match do |user|
          user_li = page.find("#users_list>li[data-id='#{user.id}']")
          expect(user_li).to have_content("@#{user.name}")
          css_class = online ? 'text-success' : 'text-danger'
          expect(user_li.find(".online-indicator.#{css_class}")).to be_truthy
        end
      end

      # the first users goes to the chat and should see only himself
      in_browser(user) do
        login(user)
        visit "/chats/#{chat.name}"

        expect(user).to have_online_state(true)
      end

      # the other one goes to the same chat
      in_browser(other_user) do
        login(other_user)
        visit "/chats/#{chat.name}"
      end

      # they both should see each other
      [user, other_user].each do |current_user|
        in_browser(current_user) do
          expect(user).to have_online_state(true)
          expect(other_user).to have_online_state(true)
        end
      end

      # the first one goes away to the other page
      in_browser(user) do
        visit '/'
        expect(page.find('#chats_list')).to have_content("##{chat.name}")
      end

      # but remains online in the chat
      in_browser(other_user) do
        expect(user).to have_online_state(true)
        expect(other_user).to have_online_state(true)
      end
    end

    scenario 'Leaving a channel', :js do
      # two users go to the same chat
      [user, other_user].each do |current_user|
        in_browser(current_user) do
          login(current_user)
          visit "/chats/#{chat.name}"
        end
      end

      # one user leaves the chat
      in_browser(user) do
        click_button 'Actions'
        click_link 'Leave chat'

        expect(page.has_css?('#chat')).to be_falsey
        expect(page.find('#chats_list')).not_to have_content("##{chat.name}")
      end

      # and disappears from users list for another user
      in_browser(other_user) do
        expect(page.find('#users_list')).not_to have_content("@#{user.name}")
      end
    end

    scenario 'Receiving a new message notification', :js do
      # two users go to the same chat
      [user, other_user].each do |current_user|
        in_browser(current_user) do
          login(current_user)
          visit "/chats/#{chat.name}"
        end
      end

      # one user switches to the other chat
      in_browser(user) do
        visit "/chats/#{other_chat.name}"
        expect(page.find('#chat')).to have_content("##{other_chat.name}")
      end

      # the other user sends a message
      in_browser(other_user) do
        within('#message_form') do
          find(:css, 'input[name=message]').set('hello world')
          click_button 'Send'
        end

        expect(page.find('#messages')).to have_content('hello world')
      end

      # the first user should see a notification indicator
      in_browser(user) do
        selector = "#chats_list>li[data-chat-name='#{chat.name}'] .new-messages-indicator"
        expect(page.has_css?(selector)).to be_truthy
      end
    end
  end
end
