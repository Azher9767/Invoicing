RSpec.describe InvoiceAmountCalculator do
  context "for line item" do
    let(:line_items) { build_list(:line_item, 2) }
    let(:expected_subtotal) { 200.0 }

    it "calculate subtotal for multiple line items" do
      sub_total_amount = InvoiceAmountCalculator.new
      expect(sub_total_amount.calculate_sub_total(line_items, [])).to eq(expected_subtotal)
    end
  end

  context "for line item with tax and discount" do
    let(:line_items) { build_list(:line_item, 2) }
    let(:tax_and_discount_polies) { build_list(:tax_and_discount_poly, 1) }
    let(:expected_subtotal) { 236.0 }

    it "calculate subtotal for multiple line items" do
      sub_total_amount = InvoiceAmountCalculator.new
      expect(sub_total_amount.calculate_sub_total(line_items, tax_and_discount_polies)).to eq(expected_subtotal)
    end
  end  
end
