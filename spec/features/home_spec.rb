RSpec.describe 'Home page' do
  it 'shows the welcome message' do
    visit root_path
    user = create(:user)
    signin(user.email, 'password')
    expect(page).to have_content('Signed in successfully.')
    expect(page).to have_content('Welcome To Home')
  end
end
