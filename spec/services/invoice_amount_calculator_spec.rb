RSpec.describe InvoiceAmountCalculator do
  let(:multiple_line_items) do
    [ 
      LineItem.new({unit_rate: 4.0, quantity: 1.0}), 
      LineItem.new({unit_rate: 0.0, quantity: 0.0})
    ]
  end

  let(:expected_subtotal) do
    4.0
  end

  it "calculate subtotal for multiple line items" do
    sub_total_amount = InvoiceAmountCalculator.new
    expect(sub_total_amount.calculate_sub_total(multiple_line_items)).to eq(expected_subtotal)
  end
end
