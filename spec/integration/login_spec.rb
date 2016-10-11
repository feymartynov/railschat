require 'rails_helper'

feature 'Logging in and out' do
  given(:user) { create(:user) }

  scenario 'Logging in as an existing user' do
    visit '/login'

    within('#new_session') do
      fill_in 'Name', with: user.name
      fill_in 'Password', with: 'secret'
      click_button 'Log in'
    end

    expect(page).to have_content "Logged in as @#{user.name}"
  end

  scenario 'Trying to log in in a wrong way' do
    visit '/login'

    within('#new_session') do
      fill_in 'Name', with: user.name
      fill_in 'Password', with: '00000000000'
      click_button 'Log in'
    end

    expect(page).not_to have_content "Logged in as @#{user.name}"
    expect(page).to have_content 'Wrong name or password'
  end

  scenario 'Trying to log out' do
    login_user(user)
    visit '/'

    expect(page).to have_content "Logged in as @#{user.name}"
    click_link 'Log out'

    expect(page).not_to have_content "Logged in as @#{user.name}"
    expect(page).to have_content 'Log in'
  end
end
