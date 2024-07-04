RSpec.describe 'Product' do
  before do
    visit root_path
    user = create(:user)
    signin(user.email, 'azher@123')
    expect(page).to have_content('Signed in successfully.')
    expect(page).to have_content('Welcome To Home')
    create(:category, user: user)
  end

  it 'creates a new product' do # rubocop:disable RSpec/ExampleLength
    visit new_product_path
    within('form[action="/products"]') do
      fill_in 'product_name', with: "mobile"
      fill_in 'Description', with: 'vivo mobile'
      fill_in 'Unit rate', with: '2'
      select 'Electronic', from: 'product_category_id'
      fill_in 'Unit', with: '1'
      click_button 'Create Product'
    end

    expect(page.has_content?('Product was successfully created.')).to be(true)
    product = Product.last
    expect(page.has_content?("Name: #{product.name}")).to be(true)
    expect(page.has_content?("Description: #{product.description}")).to be(true)
    expect(page.has_content?("Unit rate: #{product.unit_rate}")).to be(true)
    expect(page.has_content?("Category: #{product.category_id}")).to be(true)
    expect(page.has_content?("Unit: #{product.unit}")).to be(true)
  end
end
