# frozen_string_literal: true

RSpec.describe Calculation::LineItemsWithTdAndItd do
  subject(:handler) { described_class.new(invoice.line_items, invoice.tax_and_discount_polies) }

  let(:invoice) { build(:invoice) }

  shared_examples 'total_and_subtotal' do
    specify do
      expect(handler.call.map { |value| value }).to eq(total_and_subtotal)
    end
  end

  before do
    invoice.line_items = line_items
    invoice.tax_and_discount_polies = invoice_tds
  end

  describe '#call' do
    context 'when line items discount and invoice discount' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'Computer work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'Diwali sale', amount: -10.0, td_type: 'discount' }])
        ]
      end

      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :discount, amount: -10)
        ]
      end

      let(:total_and_subtotal) { [81.0, 90.0, [0.0, 0.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when line items tax and invoice tax' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'Ruby work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'CGST', amount: 10.0, td_type: 'tax' }])
        ]
      end

      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :tax, amount: 18)
        ]
      end

      let(:total_and_subtotal) { [110.0, 100.0, [0.0, 0.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when line item discount and invoice tax' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'Rails work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'Diwali sale', amount: -10.0, td_type: 'discount' }])
        ]
      end

      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :tax, amount: 10)
        ]
      end

      let(:total_and_subtotal) { [99.0, 90.0, [0.0, 0.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when line item tax and invoice discount' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'Java work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'SGST', amount: 10.0, td_type: 'tax' }])
        ]
      end

      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :discount, amount: -10)
        ]
      end

      let(:total_and_subtotal) { [99.0, 100.0, [0.0, 0.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when line items multiple tax and invoice multiple tax is present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'Java work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'sales tax', amount: 18.0, td_type: 'tax' },
                                                                 { name: 'service tax', amount: 10.0,
                                                                   td_type: 'tax' }])
        ]
      end

      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :tax, amount: 10),
          build(:tax_and_discount_poly, :tax, amount: 5)
        ]
      end

      let(:total_and_subtotal) { [128.0, 100.0, [0.0, 0.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when multiple line items discount and multiple invoice discount is present' do   # conflict
      let(:line_items) do
        [
          build(:line_item, item_name: 'Python work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'Diwali sale', amount: -10.0, td_type: 'discount' },
                                                                 { name: 'Dasahra sale', amount: -5.0,
                                                                   td_type: 'discount' }])
        ]
      end

      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :discount, amount: -10),
          build(:tax_and_discount_poly, :discount, amount: -7)
        ]
      end

      let(:total_and_subtotal) { [71.56, 85.5, [0.0, 0.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when line items discount and tax, and when invoice discount and tax is present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'HTML work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'Diwali sale', amount: -10.0, td_type: 'discount' },
                                                                 { name: 'Sales tax', amount: 10.0,
                                                                   td_type: 'tax' }])
        ]
      end

      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :discount, amount: -10),
          build(:tax_and_discount_poly, :tax, amount: 10)
        ]
      end

      let(:total_and_subtotal) { [89.10, 90.0, [0.0, 0.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when line items tax and discount, and when invoice tax and discount is present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'HTML work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'Sales tax', amount: 10.0, td_type: 'tax' },
                                                                 { name: 'Diwali sale', amount: -10.0,
                                                                   td_type: 'discount' }])
        ]
      end

      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :tax, amount: 10),
          build(:tax_and_discount_poly, :discount, amount: -10)
        ]
      end

      let(:total_and_subtotal) { [89.10, 90.0, [0.0, 0.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when multiple line items has tax and invoice tax is present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'Java work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'SGST', amount: 18.0, td_type: 'tax' }]),
          build(:line_item, item_name: 'Ruby work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'GST', amount: 18.0, td_type: 'tax' }])
        ]
      end

      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :tax, amount: 10)
        ]
      end

      let(:total_and_subtotal) { [236.0, 200.0, [0.0, 0.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when multiple line items has taxes and invoices taxes and discounts are present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'Java work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'SGST', amount: 5.0, td_type: 'tax' }]),
          build(:line_item, item_name: 'Ruby work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'GST', amount: 5.0, td_type: 'tax' }])
        ]
      end

      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :tax, amount: 10),
          build(:tax_and_discount_poly, :discount, amount: -10)
        ]
      end

      let(:total_and_subtotal) { [189.0, 200.0, [0.0, 0.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when some line items have own tax and invoice tax is present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'Java work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'SGST', amount: 5.0, td_type: 'tax' }]),
          build(:line_item, item_name: 'Ruby work', unit_rate: 100, quantity: 1)
        ]
      end

      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :tax, amount: 10)
        ]
      end

      let(:total_and_subtotal) { [215.0, 200.0, [0.0, 0.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when multiple line items and invoice tds is present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'Java work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'SGST', amount: 18.0, td_type: 'tax' }]),
          build(:line_item, item_name: 'one', unit_rate: 100, quantity: 1),
          build(:line_item, item_name: 'two', unit_rate: 100, quantity: 1),
          build(:line_item, item_name: 'three', unit_rate: 100, quantity: 1)
        ]
      end

      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :discount, amount: -10),
          build(:tax_and_discount_poly, :tax, amount: 10)
        ]
      end

      let(:total_and_subtotal) { [403.20, 400.0, [0.0, 0.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when multiple line items tds and invoice tds present '  do
      let(:line_items) do
        [
          build(:line_item, item_name: 'Java work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'SGST', amount: 18.0, td_type: 'tax' }]),
          build(:line_item, item_name: 'Java work', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'Diwali sale', amount: -10.0, td_type: 'discount' }]),
          build(:line_item, item_name: 'one', unit_rate: 100, quantity: 1)
        ]
      end

      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :discount, amount: -10),
          build(:tax_and_discount_poly, :tax, amount: 10)
        ]
      end

      let(:total_and_subtotal) { [294.30, 290.0, [0.0, 0.0]] }

      it_behaves_like 'total_and_subtotal'
    end
  end
end
