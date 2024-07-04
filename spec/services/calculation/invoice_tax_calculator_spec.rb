RSpec.describe Calculation::InvoiceTaxCalculator do
  subject(:handler) { described_class.new(invoice_tax.first, invoice.line_items, sub_total, invoice_discounts) }

  let(:invoice) { build(:invoice) }

  let(:invoice_tax) do
    [
      build(:tax_and_discount_poly, :tax, amount: 18)
    ]
  end

  let(:invoice_discounts) do
    [
      build(:tax_and_discount_poly, :discount, amount: -10)
    ]
  end

  let(:sub_total) { 100.0 }

  shared_examples 'tax_amount' do
    specify do
      expect(handler.call).to eq(tax_amount)
    end
  end

  before do
    invoice.line_items = line_items
  end

  describe '#call' do
    context 'when invoice tax is present, but not applicable on line items' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'Consultation', unit_rate: 50, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'CGST', amount: 18.0, td_type: 'tax' }]),
          build(:line_item, item_name: 'Development', unit_rate: 50, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'SGST', amount: 18.0, td_type: 'tax' }]),
        ]
      end

      let(:tax_amount) { 0.0 }

      it_behaves_like 'tax_amount'

      it 'update attributes' do
        expect(handler.line_items.first.tax_and_discount_polies.size).to eq(1)
        expect(handler.line_items.last.tax_and_discount_polies.size).to eq(1)
      end
    end

    context 'when invoice tax is applicable on line items' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'Consultation', unit_rate: 50, quantity: 1),
          build(:line_item, item_name: 'Development', unit_rate: 50, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'SGST', amount: 18.0, td_type: 'tax' }])
        ]
      end

      let(:tax_amount) { 8.1 }

      it_behaves_like 'tax_amount'

      it 'update attributes' do
        expect(handler.line_items.first.tax_and_discount_polies.size).to eq(0)
        expect(handler.line_items.last.tax_and_discount_polies.size).to eq(1)
      end
    end
  end
end
