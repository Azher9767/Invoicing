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
  
  it "creates a new invoice" do
    visit new_invoice_path

    within("#new_invoice_form") do
      fill_in 'Name', with: 'Jl construction'
      select 'Pending', from: 'invoice_status'
      fill_in 'Due date', with: '2024-04-16'
      fill_in 'Payment date', with: '2024-04-16'

      container = find(:label, text: 'Line Items').ancestor(".invoice-line-items")

      within(container) do
        find('.ts-control input').send_keys("Mobile")
      end
    
      all('.ts-dropdown .ts-dropdown-content .option', text: /#{Regexp.quote("Mobile")}/i)[0].click

      fill_in 'Note', with: 'due date'
      click_button 'Create Invoice'
    end
    
    expect(page).to have_content('Invoice was successfully created.')
    invoice = Invoice.last
    expect(page).to have_content("User: #{invoice.user_id}")
    expect(page).to have_content("Sub total: #{invoice.sub_total}")
    expect(page).to have_content("Name: #{invoice.name}")
    expect(page).to have_content("Status: #{invoice.status}")
    expect(page).to have_content("#{invoice.line_items_count}")
    expect(page).to have_content("Note: #{invoice.note}")
    expect(page).to have_content("Payment date: #{invoice.payment_date}")
    expect(page).to have_content("Due date: #{invoice.due_date}")
    invoice.line_items.each do |line_item|
      expect(page).to have_content("#{line_item.item_name} | #{line_item.quantity} | #{line_item.unit_rate}")
    end
  end
end
