# frozen_string_literal: true

RSpec.describe 'Category' do
  before do
    visit root_path
    user = create(:user)
    signin(user.email, 'azher@123')
  end

  it 'create a new category' do # rubocop:disable RSpec/ExampleLength
    expect(page.has_content?('Signed in successfully.')).to be_truthy
    expect(page.has_content?('Welcome To Home')).to be_truthy
    visit new_category_path
    within('form[action="/categories"]') do
      fill_in 'category_name', with: 'Electronic'
      fill_in 'category_product_count', with: '1'
      click_button 'Save' # rubocop:disable Capybara/ClickLinkOrButtonStyle
    end

    expect(page.has_content?('Category was successfully created.')).to be_truthy
    category = Category.last
    expect(page.has_content?("Name: #{category.name}")).to be_truthy
    expect(page.has_content?("User: #{category.user_id}")).to be_truthy
    expect(category.product_count).to eq(1)
  end
end
