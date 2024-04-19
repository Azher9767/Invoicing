RSpec.describe InvoiceAmountCalculator do
  context "for line item" do
    let(:multiple_line_items) do
      [ 
        LineItem.new({unit_rate: 4.0, quantity: 1.0}), 
        LineItem.new({unit_rate: 0.0, quantity: 0.0})
      ]
    end

    let(:tax_and_discount_poly_item) do
      [
        TaxAndDiscountPoly.new({amount: 0.0})
      ]
    end

    let(:expected_subtotal) do
      4.0
    end

    it "calculate subtotal for multiple line items" do
      sub_total_amount = InvoiceAmountCalculator.new
      expect(sub_total_amount.calculate_sub_total(multiple_line_items, tax_and_discount_poly_item)).to eq(expected_subtotal)
    end
  end

  context "for non fixe tax and discount" do
    let(:multiple_line_items) do
      [ 
        LineItem.new({unit_rate: 100.0, quantity: 2.0}), 
        LineItem.new({unit_rate: 0.0, quantity: 0.0})
      ]
    end

    let(:tax_and_discount_poly) do
      [
        TaxAndDiscountPoly.new({amount: 18.0, tax_type: 'percentage'})
      ]
    end
  
    let(:expected_subtotal) do
      236.0
    end

    it "calculate subtotal for line item with tax and discount" do
      sub_total_amount = InvoiceAmountCalculator.new
      expect(sub_total_amount.calculate_sub_total(multiple_line_items, tax_and_discount_poly)).to eq(expected_subtotal)
    end
  end

  context "for fixed tax/discount" do
    let(:multiple_line_items) do
      [ 
        LineItem.new({unit_rate: 100.0, quantity: 2.0})
      ]
    end

    let(:tax_and_discount_poly) do
      [
        TaxAndDiscountPoly.new({amount: -18.0, tax_type: 'fixed'})
      ]
    end
  
    let(:expected_subtotal) do
      182.0
    end

    it "calculate subtotal for line item with fixed tax and discount" do
      sub_total_amount = InvoiceAmountCalculator.new
      expect(sub_total_amount.calculate_sub_total(multiple_line_items, tax_and_discount_poly)).to eq(expected_subtotal)
    end
  end
end
