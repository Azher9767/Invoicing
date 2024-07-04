RSpec.describe InvoiceAmountCalculator do
  subject(:handler) { described_class.new(line_items, invoice_tds) }

  describe '#only_line_items?' do
    context "only line items" do
      let(:line_items) { build_list(:line_item, 2) }
      let(:invoice_tds) { [] } 

      specify do
        expect(handler.only_line_items?).to be_truthy
      end
    end

    context 'when invoice td is present' do
      let(:line_items) { build_list(:line_item, 2) }
      let(:invoice_tds) { [build(:tax_and_discount_poly, :tax)] }  

      specify do
        expect(handler.only_line_items?).to be_falsey
      end
    end

    context 'when line items td is present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'first', unit_rate: 100, quantity: 1,
                tax_and_discount_polies_attributes: [{name: 'CGST 18.0 %', amount: 18.0, td_type: 'tax'}])
        ]
      end

      let(:invoice_tds) { [] }  

      specify do
        expect(handler.only_line_items?).to be_falsey
      end
    end

    context 'when line items td and invoice td is present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'first', unit_rate: 100, quantity: 1,
                tax_and_discount_polies_attributes: [{name: 'CGST 18.0 %', amount: 18.0, td_type: 'tax'}])
        ]
      end

      let(:invoice_tds) { [build(:tax_and_discount_poly, :tax)] }  

      specify do
        expect(handler.only_line_items?).to be_falsey
      end
    end
  end

  describe '#td_on_invoice_only?' do
    context 'when td on invoice only is present' do
      let(:line_items) { build_list(:line_item, 2) }
      let(:invoice_tds) { [build(:tax_and_discount_poly, :tax)] }  

      specify do
        expect(handler.td_on_invoice_only?).to be_truthy
      end
    end

    context 'when td on invoice is present and also line items td is present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'first', unit_rate: 100, quantity: 1,
                tax_and_discount_polies_attributes: [{name: 'CGST 18.0 %', amount: 18.0, td_type: 'tax'}])
        ]
      end
      
      let(:invoice_tds) { [build(:tax_and_discount_poly, :tax)] }  

      specify do
        expect(handler.td_on_invoice_only?).to be_falsey
      end
    end
  end

  describe '#td_in_line_items_only?' do
    context 'when td in line items only' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'first', unit_rate: 100, quantity: 1,
                tax_and_discount_polies_attributes: [{name: 'CGST 18.0 %', amount: 18.0, td_type: 'tax'}])
        ]
      end

      let(:invoice_tds) { [] }

      specify do
        expect(handler.td_in_line_items_only?).to be_truthy
      end
    end

    context 'when only td in line items but invoice td is also present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'first', unit_rate: 100, quantity: 1,
                tax_and_discount_polies_attributes: [{name: 'CGST 18.0 %', amount: 18.0, td_type: 'tax'}])
        ]
      end
      
      let(:invoice_tds) { [build(:tax_and_discount_poly, :tax)] }  

      specify do
        expect(handler.td_on_invoice_only?).to be_falsey
      end
    end
  end

  describe '#td_in_line_items_and_invoice?' do
    context 'when both td in line items and td on invoice' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'first', unit_rate: 100, quantity: 1,
                tax_and_discount_polies_attributes: [{name: 'CGST 18.0 %', amount: 18.0, td_type: 'tax'}])
        ]
      end
      
      let(:invoice_tds) { [build(:tax_and_discount_poly, :tax)] }  
  
      specify do
        expect(handler.td_in_line_items_and_invoice?).to be_truthy
      end
    end

    context 'when line items discount is present and invoice tax is present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'second', unit_rate: 100, quantity: 1,
                tax_and_discount_polies_attributes: [{name: 'Diwali Sale 10.0 %', amount: -10.0, td_type: 'discount'}])
        ]
      end
      
      let(:invoice_tds) { [build(:tax_and_discount_poly, :tax)] }  
  
      specify do
        expect(handler.td_in_line_items_and_invoice?).to be_truthy
      end
    end

    context 'when multiple line items' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'first', unit_rate: 50, quantity: 1, tax_and_discount_polies_attributes: []),
          build(:line_item, item_name: 'first', unit_rate: 50, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'CGST 18.0 %', amount: 18.0, td_type: 'tax' }])
        ]
      end

      let(:invoice_tds) do 
        [
          build(:tax_and_discount_poly, :tax, amount: 18.0),
          build(:tax_and_discount_poly, :discount, amount: -10.0)
        ]
      end

      specify do
        expect(handler.td_in_line_items_and_invoice?).to be_truthy
        expect(handler.call).to eq([106.2, 100, [8.1, -10]])
      end
    end
  end
end
