RSpec.describe 'Product' do
  it 'creates a new product' do
    visit root_path
    user = create(:user)
    signin(user.email, 'azher@123')

    create(:category, user: user)
    visit new_product_path
   
    fill_in 'Name', with: "mobile"
    fill_in 'Description', with: 'vivo mobile'
    fill_in 'Unit rate', with: '2'
    select 'Automotive', from: 'product_category_id'
    fill_in 'Unit', with: '1'
    click_button 'Create Product'
    sleep(5)

    expect(page).to have_content('Product was successfully created.')
    sleep(10)
  end
end
