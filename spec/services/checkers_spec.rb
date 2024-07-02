RSpec.describe Checkers do
  let(:invoice_amount_calculator) do
    Class.new do
      include Checkers

      def initialize(line_items, itds)
        @line_items = line_items
        @itds = itds
      end
    end.new(invoice.line_items, invoice.tax_and_discount_polies)
  end
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user) }
  let!(:product) { create(:product, id: 1001, category: category) }
  let!(:product2) { create(:product, id: 1002, category: category) }
  let(:tax) { create(:tax_and_discount, id: 2000, name: 'CGST', td_type: 'tax', amount: 18, user: user) }
  let(:discount) { create(:tax_and_discount, id: 2001, name: 'Sale', td_type: 'discount', amount: -10, user: user) }

  let(:consultation) { build(:line_item, item_name: 'Consultation', unit_rate: 5.0, quantity: 10, unit: 'pc', product: product) }
  let(:development) { build(:line_item, item_name: 'Development', unit_rate: 10.0, quantity: 5, unit: 'pc', product: product2) }

  let(:poly_id_one) { 1000 }
  let(:poly_id_two) { 1001 }
  let(:invoice) do
    invoice = build(:invoice, user_id: user.id, name: 'invoice').tap do |r|
      # line items tds
      consultation.tax_and_discount_polies << build(:tax_and_discount_poly, id: poly_id_one, tax_and_discount: tax, name: 'GST', amount: 18,
                                                                            td_type: 'tax')
      development.tax_and_discount_polies << build(:tax_and_discount_poly, id: poly_id_two, tax_and_discount: tax, name: 'GST', amount: 18,
                                                                           td_type: 'tax')
      r.line_items << consultation
      r.line_items << development

      # invoice tds
      r.tax_and_discount_polies << build(:tax_and_discount_poly, tax_and_discount: tax, name: 'GST', amount: 18, td_type: 'tax')
      r.tax_and_discount_polies << build(:tax_and_discount_poly, tax_and_discount: discount, name: 'Sale', amount: -10, td_type: 'discount')
    end
    invoice
  end

  describe '#only_line_items?' do
    it 'returns true if there are no tds in line items and invoice' do
      allow(invoice).to receive(:tax_and_discount_polies).and_return([])
      allow(invoice.line_items.first).to receive(:tax_and_discount_polies).and_return([])
      allow(invoice.line_items.second).to receive(:tax_and_discount_polies).and_return([])

      expect(invoice_amount_calculator.only_line_items?).to be true
    end

    it 'returns false if there are tds in line items' do
      allow(invoice).to receive(:tax_and_discount_polies).and_return([])
      allow(invoice.line_items.second).to receive(:tax_and_discount_polies).and_return([])

      expect(invoice_amount_calculator.only_line_items?).to be false
    end

    it 'returns false if there are tds in invoice and in line items as well' do
      expect(invoice_amount_calculator.only_line_items?).to be false
    end

    it 'returns false if there are tds in invoice only' do
      allow(invoice.line_items.first).to receive(:tax_and_discount_polies).and_return([])
      allow(invoice.line_items.second).to receive(:tax_and_discount_polies).and_return([])

      expect(invoice_amount_calculator.only_line_items?).to be false
    end
  end

  describe '#td_in_line_items_and_invoice?' do
    it 'returns true if there are tds in line items and invoice' do
      expect(invoice_amount_calculator.td_in_line_items_and_invoice?).to be true
    end

    it 'returns false if there are no tds in line items' do
      allow(invoice.line_items.first).to receive(:tax_and_discount_polies).and_return([])
      allow(invoice.line_items.second).to receive(:tax_and_discount_polies).and_return([])

      expect(invoice_amount_calculator.td_in_line_items_and_invoice?).to be false
    end

    it 'returns false if there are no tds in invoice' do
      allow(invoice).to receive(:tax_and_discount_polies).and_return([])

      expect(invoice_amount_calculator.td_in_line_items_and_invoice?).to be false
    end

    it 'returns false if there are no tds in line items and invoice' do
      allow(invoice).to receive(:tax_and_discount_polies).and_return([])
      allow(invoice.line_items.first).to receive(:tax_and_discount_polies).and_return([])
      allow(invoice.line_items.second).to receive(:tax_and_discount_polies).and_return([])

      expect(invoice_amount_calculator.td_in_line_items_and_invoice?).to be false
    end
  end

  describe '#any_line_item_with_tds?' do
    it 'returns true if there are tds in line items and none of them are marked for destruction' do
      expect(invoice_amount_calculator.any_line_item_with_tds?).to be true
    end

    it 'returns false if there are tds in line items and they are marked for destruction' do
      allow(invoice.line_items.first.tax_and_discount_polies.first).to receive(:marked_for_destruction?).and_return(true)
      allow(invoice.line_items.last.tax_and_discount_polies.first).to receive(:marked_for_destruction?).and_return(true)

      expect(invoice_amount_calculator.any_line_item_with_tds?).to be false
    end

    it 'returns true if there are tds in line items and one line item has td marked for destruction' do
      allow(invoice.line_items.first.tax_and_discount_polies.first).to receive(:marked_for_destruction?).and_return(true)

      expect(invoice_amount_calculator.any_line_item_with_tds?).to be true
    end

    it 'returns false if there are no tds in line items' do
      allow(invoice.line_items.first).to receive(:tax_and_discount_polies).and_return([])
      allow(invoice.line_items.second).to receive(:tax_and_discount_polies).and_return([])

      expect(invoice_amount_calculator.any_line_item_with_tds?).to be false
    end
  end

  describe '#td_on_invoice_only?' do
    it 'returns true if there are tds in invoice only' do
      allow(invoice.line_items.first).to receive(:tax_and_discount_polies).and_return([])
      allow(invoice.line_items.second).to receive(:tax_and_discount_polies).and_return([])

      expect(invoice_amount_calculator.td_on_invoice_only?).to be true
    end

    it 'returns false if there are no tds in invoice' do
      allow(invoice).to receive(:tax_and_discount_polies).and_return([])

      expect(invoice_amount_calculator.td_on_invoice_only?).to be false
    end

    it 'returns false if there are tds in line items and invoice both' do
      expect(invoice_amount_calculator.td_on_invoice_only?).to be false
    end
  end
end
