RSpec.describe Calculation::LineItemsWithTd do
  subject(:handler) { described_class.new(line_items) }

  shared_examples 'total_and_subtotal' do
    specify do
      expect(handler.call).to eq(total_and_subtotal)
    end
  end

  describe '#call' do
    let(:line_items_total) { 200.0 }

    context 'when both tax and discount are present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'first', unit_rate: 100, quantity: 1),
          build(:line_item, item_name: 'second', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'CGST', amount: 10.0, td_type: 'tax' }]),
          build(:line_item, item_name: 'third', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'Diwali Sale', amount: -10.0, td_type: 'discount' }])
        ]
      end

      let(:total_and_subtotal) { [300.0, 290.0, [10.0, -10.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when only taxes are present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'first', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{name: '10 %', amount: 10.0, td_type: 'tax'}]),

          build(:line_item, item_name: 'second', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{name: '10 %', amount: 10.0, td_type: 'tax'}])
        ]
      end
      let(:total_and_subtotal) { [220.0, 200.0, [20.0, 0.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when only discounts are present' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'first', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: '10 %', amount: -10.0, td_type: 'discount' }]),

          build(:line_item, item_name: 'second', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: '10 %', amount: -10.0, td_type: 'discount' }])
        ]
      end
      let(:total_and_subtotal) { [180, 180, [0.0, -20.0]] }

      it_behaves_like 'total_and_subtotal'
    end

    context 'when lineitems have both taxes and discounts' do
      let(:line_items) do
        [
          build(:line_item, item_name: 'first', unit_rate: 100, quantity: 1),
          build(:line_item, item_name: 'second', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'CGST', amount: 10.0, td_type: 'tax' },
                                                                 { name: 'Diwali Sale', amount: -10.0, td_type: 'discount' }]),

          build(:line_item, item_name: 'third', unit_rate: 100, quantity: 1,
                            tax_and_discount_polies_attributes: [{ name: 'CGST', amount: 10.0, td_type: 'tax' },
                                                                 { name: 'Diwali Sale', amount: -10.0, td_type: 'discount' }])
        ]
      end
      let(:total_and_subtotal) { [298, 280.0, [18.0, -20.0]] }

      it_behaves_like 'total_and_subtotal'
    end
  end
end
