require 'rails_helper'

feature 'Registration' do
  scenario 'Registering a new user' do
    visit '/users/new'

    within('#new_user') do
      fill_in 'Name', with: 'dude'
      fill_in 'Password', with: 'qwerty'
      fill_in 'Password confirmation', with: 'qwerty'
      click_button 'Register'
    end

    expect(page).to have_content 'Logged in as @dude'
  end

  scenario 'Trying to register in a wrong way' do
    visit '/users/new'

    within('#new_user') do
      fill_in 'Name', with: 'dude'
      fill_in 'Password', with: 'qwerty'
      fill_in 'Password confirmation', with: 'ytrewq'
      click_button 'Register'
    end

    expect(page).not_to have_content 'Logged in as @dude'
    expect(page).to have_content "Password confirmation doesn't match Password"
  end
end
