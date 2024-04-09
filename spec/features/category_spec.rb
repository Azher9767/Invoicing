RSpec.describe 'Category' do
  before do
    visit root_path
    user = create(:user)
    signin(user.email, 'azher@123')
    expect(page).to have_content('Signed in successfully.')
    expect(page).to have_content('Welcome To Home')
  end

  it 'create a new category' do
    visit new_category_path

    fill_in 'Name', with: 'electronics'
    fill_in 'Product count', with: '1'
    click_button 'Save'

    expect(page).to have_content('Category was successfully created.')
    category = Category.last

    expect(page).to have_content("Name: #{category.name}")
    expect(page).to have_content("User: #{category.user_id}")
    expect(category.product_count).to eq(1) 
    
    # visit edit_category_path(Category.last)
    # fill_in 'Name', with: 'Mobile'
    # fill_in 'Product count', with: '1'
    # click_button 'Save'
    # sleep(5)
  end
end
