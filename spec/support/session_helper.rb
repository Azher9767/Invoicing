module SessionHelpers
  def sign_up_with(email, password, confirmation, country)
    visit new_user_registration_path
    fill_in 'Your email', with: email
    fill_in 'Password', with: password
    fill_in 'Confirm password', with: confirmation
    select 'India', from: 'user[country]'
    click_button 'Sign up'
  end

  def signin(email, password)
    visit new_user_session_path
    fill_in 'user[email]', with: email
    fill_in 'user[password]', with: password
    find('input[type=submit]').click
  end
end

RSpec.configure do |config|
  config.include SessionHelpers, type: :feature
end
