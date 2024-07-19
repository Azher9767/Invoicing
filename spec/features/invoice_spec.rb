RSpec.describe 'Invoice', :js do
  before do
    visit root_path
    user = create(:user)
    signin(user.email, 'azher@123')
    expect(page).to have_content('Signed in successfully.')
    expect(page).to have_content('Welcome To Home')
    category = create(:category, user:)
    create(:product, category:, unit_rate: 1)
  end

  it 'creates a new invoice' do # rubocop:disable RSpec/ExampleLength
    visit new_invoice_path
    within('#new_invoice_form') do
      fill_in 'Name', with: 'Jl construction'
      select 'Pending', from: 'invoice_status'
      fill_in 'Due date', with: '2024-04-16'
      fill_in 'Payment date', with: '2024-04-16'

      container = find(:xpath, "//label[text()='Line items']/following-sibling::div[contains(@class, 'ts-wrapper')][1]")

      within(container) do
        find('.ts-control input').send_keys('Mobile')
      end

      all('.ts-dropdown .ts-dropdown-content .option', text: /#{Regexp.quote('Mobile')}/i)[0].click

      fill_in 'Note', with: 'due date'
      click_button 'Create Invoice' # rubocop:disable Capybara/ClickLinkOrButtonStyle
    end

    expect(page.has_content?('Invoice was successfully created.')).to be_truthy
    invoice = Invoice.last
    expect(page.has_content?("User: #{invoice.user_id}")).to be_truthy
    expect(page.has_content?("Sub total: #{invoice.sub_total}")).to be_truthy
    expect(page.has_content?("Name: #{invoice.name}")).to be_truthy
    expect(page.has_content?("Status: #{invoice.status}")).to be_truthy
    expect(page.has_content?(invoice.line_items_count.to_s)).to be_truthy
    expect(page.has_content?("Note: #{invoice.note}")).to be_truthy
    expect(page.has_content?("Payment date: #{invoice.payment_date}")).to be_truthy
    expect(page.has_content?("Due date: #{invoice.due_date}")).to be_truthy
    invoice.line_items.each do |line_item|
      expect(page.has_content?("#{line_item.item_name} | #{line_item.quantity} | #{line_item.unit_rate}")).to be_truthy
    end
  end
end
