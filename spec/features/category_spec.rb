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
    within('form[action="/categories"]') do
      fill_in 'Name', with: 'electronics'
      fill_in 'Product count', with: '1'
      click_button 'Save'
    end

    expect(page).to have_content('Category was successfully created.')
    category = Category.last
    expect(page).to have_content("Name: #{category.name}")
    expect(page).to have_content("User: #{category.user_id}")
    expect(category.product_count).to eq(1) 
  end
end
