RSpec.describe 'Category' do
  it 'create a new category' do
    visit root_path
    user = create(:user)
    signin(user.email, 'azher@123')
    expect(page).to have_content('Signed in successfully.')
    expect(page).to have_content('Welcome To Home')

    sleep(2)

    visit new_category_path

    fill_in 'Name', with: 'electronics'
    fill_in 'Product count', with: '1'
    click_button 'Save'

    sleep(2)

    expect(page).to have_content('Category was successfully created.')
    expect(Category.count).to eq(1) 
    
    visit edit_category_path(Category.last)

    fill_in 'Name', with: 'Mobile'
    fill_in 'Product count', with: '2'
    click_button 'Save'
    sleep(5)
  end
end
