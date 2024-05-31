RSpec.describe Calculation::InvoiceWithTd do
  subject(:handler) { described_class.new(line_items, invoice_tds) }

  shared_examples 'total_and_subtotal' do
    specify do
      expect(handler.call).to eq(total_and_subtotal)
    end
  end
  
  context "#call" do
    let(:line_items) { build_list(:line_item, 2) }
    let(:sub_total) { 200.0 }
    
    context 'when both tax and discount are present' do
      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :tax, amount: 10),
          build(:tax_and_discount_poly, :discount, amount: -10)
        ]
      end
  
      let(:total_and_subtotal) { [198.0, sub_total] }
  
      it_behaves_like 'total_and_subtotal'
    end

    context 'when only discount is present' do
      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :discount, amount: -10)
        ]
      end

      let(:total_and_subtotal) { [180.0, sub_total] }
  
      it_behaves_like 'total_and_subtotal'
    end

    context 'when only tax is present' do
      let(:invoice_tds) do
        [
          build(:tax_and_discount_poly, :tax, amount: 10)
        ]
      end

      let(:total_and_subtotal) { [220.0, sub_total] }
  
      it_behaves_like 'total_and_subtotal'
    end

    
  end
end
