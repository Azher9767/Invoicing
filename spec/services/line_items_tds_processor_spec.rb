# frozen_string_literal: true

RSpec.describe LineItemsTdsProcessor do
  subject(:processor) { described_class.new(existing_line_items, new_line_items) }

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
    invoice.save!
    invoice
  end

  let(:existing_line_items) do
    invoice.line_items
  end

  let(:new_line_items) do
    HashWithIndifferentAccess.new({
                                    consultation.id.to_s => {
                                      'item_name' => 'Travel Service',
                                      'quantity' => consultation.quantity,
                                      'unit_rate' => consultation.unit_rate,
                                      'unit' => 'hrs',
                                      'tax_and_discount_ids' => consultation_polies, # all tax/discounts are removed
                                      'product_id' => consultation.product.id,
                                      'id' => consultation.id.to_s
                                    },
                                    development.id.to_s => {
                                      'item_name' => 'Bike Work',
                                      'quantity' => 10,
                                      'unit_rate' => 1000,
                                      'unit' => 'hrs',
                                      'tax_and_discount_ids' => [tax.id],
                                      'id' => development.id.to_s,
                                      'product_id' => nil
                                    }
                                  })
  end

  let(:consultation_polies) { [] }

  context 'with comparison' do
    context 'when all polies are removed' do
      it 'verifies the existing line items hash' do
        expect(processor.send(:prepare_hash_for_existing)).to eq({ consultation.id.to_s => { tax.id.to_s => poly_id_one.to_s },
                                                                   development.id.to_s => { tax.id.to_s => poly_id_two.to_s } })
      end

      it 'verfies the new line items hash' do
        expect(processor.send(:prepare_hash_for_new)).to eq({ consultation.id.to_s => [], development.id.to_s => [tax.id.to_s] })
      end

      specify do
        processor.process
        invoice.line_items.first.tax_and_discount_polies.each do |poly|
          expect(poly.marked_for_destruction?).to be_truthy
        end
      end
    end

    context 'when a new poly has been added' do
      let(:consultation_polies) { [tax.id, discount.id] }

      it 'verifies the existing line items hash' do
        expect(processor.send(:prepare_hash_for_existing)).to eq({ consultation.id.to_s => { tax.id.to_s => poly_id_one.to_s },
                                                                   development.id.to_s => { tax.id.to_s => poly_id_two.to_s } })
      end

      it 'verfies the new line items hash' do
        expect(processor.send(:prepare_hash_for_new)).to eq({ consultation.id.to_s => [tax.id.to_s, discount.id.to_s], development.id.to_s => [tax.id.to_s] })
      end

      specify do
        processor.process
        expect(invoice.line_items.first.tax_and_discount_polies.size).to eq(2)
      end
    end

    context 'when a existing poly has been removed' do
      let(:invoice) do
        invoice = build(:invoice, user_id: user.id, name: 'invoice').tap do |r|
          # line items tds
          consultation.tax_and_discount_polies << build(:tax_and_discount_poly, id: poly_id_one, tax_and_discount: tax, name: 'GST', amount: 18,
                                                                                td_type: 'tax')
          consultation.tax_and_discount_polies << build(:tax_and_discount_poly, id: 2003, tax_and_discount: discount, name: 'Sale', amount: -10,
                                                                                td_type: 'discount')
          development.tax_and_discount_polies << build(:tax_and_discount_poly, id: poly_id_two, tax_and_discount: tax, name: 'GST', amount: 18,
                                                                               td_type: 'tax')
          r.line_items << consultation
          r.line_items << development

          # invoice tds
          r.tax_and_discount_polies << build(:tax_and_discount_poly, tax_and_discount: tax, name: 'GST', amount: 18, td_type: 'tax')
          r.tax_and_discount_polies << build(:tax_and_discount_poly, tax_and_discount: discount, name: 'Sale', amount: -10, td_type: 'discount')
        end
        invoice.save!
        invoice
      end

      let(:consultation_polies) { [discount.id] }

      it 'verifies the existing line items hash' do
        expect(processor.send(:prepare_hash_for_existing)).to eq({ consultation.id.to_s => { tax.id.to_s => poly_id_one.to_s, discount.id.to_s => 2003.to_s},
                                                                   development.id.to_s => { tax.id.to_s => poly_id_two.to_s } })
      end

      it 'verfies the new line items hash' do
        expect(processor.send(:prepare_hash_for_new)).to eq({ consultation.id.to_s => [discount.id.to_s], development.id.to_s => [tax.id.to_s] })
      end

      specify do
        processor.process
        expect(invoice.line_items.first.tax_and_discount_polies.size).to eq(2)
        expect(invoice.line_items.first.tax_and_discount_polies.first.marked_for_destruction?).to be_truthy
        expect(invoice.line_items.first.tax_and_discount_polies.last.marked_for_destruction?).to be_falsy
      end
    end

    context 'when a existing poly has been removed and new poly has been added on the same line_item' do
      let(:invoice) do
        invoice = build(:invoice, user_id: user.id, name: 'invoice').tap do |r|
          # line items tds
          consultation.tax_and_discount_polies << build(:tax_and_discount_poly, id: poly_id_one, tax_and_discount: tax, name: 'GST', amount: 18,
                                                                                td_type: 'tax')
          r.line_items << consultation

          # invoice tds
          r.tax_and_discount_polies << build(:tax_and_discount_poly, tax_and_discount: tax, name: 'GST', amount: 18, td_type: 'tax')
          r.tax_and_discount_polies << build(:tax_and_discount_poly, tax_and_discount: discount, name: 'Sale', amount: -10, td_type: 'discount')
        end
        invoice.save!
        invoice
      end

      let(:consultation_polies) { [discount.id] }

      let(:new_line_items) do
        HashWithIndifferentAccess.new({
                                        consultation.id.to_s => {
                                          'item_name' => 'Travel Service',
                                          'quantity' => consultation.quantity,
                                          'unit_rate' => consultation.unit_rate,
                                          'unit' => 'hrs',
                                          'tax_and_discount_ids' => consultation_polies, # all tax/discounts are removed
                                          'product_id' => consultation.product.id,
                                          'id' => consultation.id.to_s
                                        }
                                      })
      end

      it 'verifies the existing line items hash' do
        expect(processor.send(:prepare_hash_for_existing)).to eq({ consultation.id.to_s => { tax.id.to_s => poly_id_one.to_s}})
      end

      it 'verfies the new line items hash' do
        expect(processor.send(:prepare_hash_for_new)).to eq({ consultation.id.to_s => [discount.id.to_s] })
      end

      specify do
        processor.process
        expect(invoice.line_items.first.tax_and_discount_polies.size).to eq(2)
        expect(invoice.line_items.first.tax_and_discount_polies.first.marked_for_destruction?).to be_truthy
        expect(invoice.line_items.first.tax_and_discount_polies.last.marked_for_destruction?).to be_falsey
      end
    end
  end

  context 'when new line is added' do
    let(:new_line_item) do
      {
        'item_name' => 'New line item',
        'quantity' => 10,
        'unit_rate' => 1000,
        'unit' => 'hrs',
        'tax_and_discount_ids' => [discount.id],
        'product_id' => nil
      }
    end

    let(:new_line_items) do
      HashWithIndifferentAccess.new({
                                      consultation.id.to_s => {
                                        'item_name' => 'Travel Service',
                                        'quantity' => consultation.quantity,
                                        'unit_rate' => consultation.unit_rate,
                                        'unit' => 'hrs',
                                        'tax_and_discount_ids' => consultation_polies, # all tax/discounts are removed
                                        'product_id' => consultation.product.id,
                                        'id' => consultation.id.to_s
                                      },
                                      development.id.to_s => {
                                        'item_name' => 'Bike Work',
                                        'quantity' => 10,
                                        'unit_rate' => 1000,
                                        'unit' => 'hrs',
                                        'tax_and_discount_ids' => [tax.id],
                                        'product_id' => development.product.id,
                                        'id' => development.id.to_s
                                      },
                                      '1232342342' => new_line_item
                                    })
    end

    before do
      # we need to build the new line item as the class accepts the built line items objects
      invoice.line_items.build(new_line_item.except(:tax_and_discount_ids))
    end

    it 'verifies the existing line items hash' do
      expect(processor.send(:prepare_hash_for_existing)).to eq({ consultation.id.to_s => { tax.id.to_s => poly_id_one.to_s },
                                                                 development.id.to_s => { tax.id.to_s => poly_id_two.to_s },
                                                                 "" => { 2001.to_s => "" } })
    end

    it 'verfies the new line items hash' do
      expect(processor.send(:prepare_hash_for_new)).to eq({ consultation.id.to_s => [], development.id.to_s => [tax.id.to_s], '1232342342' => [discount.id.to_s] })
    end

    specify do
      processor.process
      expect(invoice.line_items.size).to eq(3)
      expect(invoice.line_items.last.tax_and_discount_polies.size).to eq(1)
    end
  end

  context 'when both invoice tax and line item tax is present and existing tax of line item has been remove' do
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
      invoice.save!
      invoice
    end

    let(:consultation_polies) { [] }

    it 'verifies the existing line items hash' do
      expect(processor.send(:prepare_hash_for_existing)).to eq({ consultation.id.to_s => { tax.id.to_s => poly_id_one.to_s},
                                                                 development.id.to_s => { tax.id.to_s => poly_id_two.to_s } })
    end

    it 'verfies the new line items hash' do
      expect(processor.send(:prepare_hash_for_new)).to eq({ consultation.id.to_s => [], development.id.to_s => [tax.id.to_s] })
    end

    specify do
      processor.process
      expect(invoice.line_items.first.tax_and_discount_polies.size).to eq(1)
      expect(invoice.line_items.first.tax_and_discount_polies.first.marked_for_destruction?).to be_truthy
    end
  end
end
