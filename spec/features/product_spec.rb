RSpec.describe 'Product' do
  before do
    visit root_path
    user = create(:user)
    signin(user.email, 'azher@123')
    create(:category, user: user)
  end

  it 'creates a new product' do
    visit new_product_path
    within('form[action="/products"]') do
      fill_in 'Name', with: "mobile"
      fill_in 'Description', with: 'vivo mobile'
      fill_in 'Unit rate', with: '2'
      select 'Electronic', from: 'product_category_id'
      fill_in 'Unit', with: '1'
      click_button 'Create Product'
    end

    expect(page).to have_content('Product was successfully created.')
    product = Product.last
    expect(page).to have_content("Name: #{product.name}")
    expect(page).to have_content("Description: #{product.description}")
    expect(page).to have_content("Unit rate: #{product.unit_rate}")
    expect(page).to have_content("Category: #{product.category_id}")
    expect(page).to have_content("Unit: #{product.unit}")
  end
end
