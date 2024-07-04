# frozen_string_literal: true

RSpec.describe InvoiceObjectBuilderForUpdate do
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user) }
  let!(:product) { create(:product, id: 1001, category: category) }
  let!(:product2) { create(:product, id: 1002, category: category) }
  let(:tax) { create(:tax_and_discount, name: 'CGST', td_type: 'tax', amount: 18, user: user) }
  let(:discount) { create(:tax_and_discount, name: 'Sale', td_type: 'discount', amount: -10, user: user) }

  let(:consultation) { build(:line_item, item_name: 'Consultation', unit_rate: 5.0, quantity: 10, unit: 'pc', product: product) }
  let(:development) { build(:line_item, item_name: 'Development', unit_rate: 10.0, quantity: 5, unit: 'pc', product: product2) }

  let(:invoice) do
    invoice = build(:invoice, user_id: user.id, name: 'invoice').tap do |r|
      # line items tds
      consultation.tax_and_discount_polies << build(:tax_and_discount_poly, tax_and_discount: tax, name: 'GST', amount: 18, td_type: 'tax')
      development.tax_and_discount_polies << build(:tax_and_discount_poly, tax_and_discount: tax, name: 'GST', amount: 18, td_type: 'tax')
      r.line_items << consultation
      r.line_items << development

      # invoice tds
      r.tax_and_discount_polies << build(:tax_and_discount_poly, tax_and_discount: tax, name: 'GST', amount: 18, td_type: 'tax')
      r.tax_and_discount_polies << build(:tax_and_discount_poly, tax_and_discount: discount, name: 'Sale', amount: -10, td_type: 'discount')
    end
    invoice.save!
    invoice
  end

  let(:tax_policy) { invoice.tax_and_discount_polies.find_by(td_type: 'tax') }
  let(:discount_policy) { invoice.tax_and_discount_polies.find_by(td_type: 'discount') }

  context 'for line item only' do # rubocop:disable RSpec/ContextWording
    let(:invoice_params) do
      HashWithIndifferentAccess.new({
                                      'id' => invoice.id,
                                      'name' => 'invoice new',
                                      'due_date' => invoice.due_date,
                                      'payment_date' => invoice.payment_date,
                                      'line_items_attributes' => {
                                        consultation.id => {
                                          'item_name' => 'Travel Service',
                                          'quantity' => consultation.quantity,
                                          'unit_rate' => consultation.unit_rate,
                                          'unit' => 'hrs',
                                          'tax_and_discount_ids' => [],
                                          'product_id' => consultation.product.id,
                                          'id' => consultation.id.to_s
                                        },
                                        '1232342342' => {
                                          'item_name' => 'Bike Work',
                                          'quantity' => 10,
                                          'unit_rate' => 1000,
                                          'unit' => 'hrs',
                                          'tax_and_discount_ids' => [discount.id, tax.id],
                                          'product_id' => nil
                                        }
                                      },
                                      'tax_and_discount_polies_attributes' => {
                                        tax_policy.id => {
                                          'name' => 'New Tax',
                                          'amount' => tax.amount,
                                          'td_type' => tax.td_type,
                                          'tax_and_discount_id' => tax.id,
                                          'id' => tax_policy.id
                                        },
                                        discount_policy.id => {
                                          'name' => discount.name,
                                          'amount' => discount.amount,
                                          'td_type' => discount.td_type,
                                          'tax_and_discount_id' => discount.id,
                                          'id' => discount_policy.id
                                        }
                                      },
                                      'note' => ''
                                    })
    end

    it 'updates the attributes' do # rubocop:disable RSpec/ExampleLength
      invoice_object = described_class.new(invoice.id, invoice_params).call

      expect(invoice_object.is_a?(Invoice)).to be(true)
      expect(invoice_object.changed?).to be_truthy
      expect(invoice_object.changes).to eq({ 'name' => ['invoice', 'invoice new'], 'note' => ['This is a sales invoice', ''] })
      expect(invoice_object.line_items[1].marked_for_destruction?).to be_truthy
      expect(invoice_object.line_items[2]).to have_attributes({
                                                                'item_name' => 'Bike Work',
                                                                'quantity' => 10.0,
                                                                'unit_rate' => 1000.0,
                                                                'unit' => 'hrs',
                                                                'product_id' => nil
                                                              })
      expect(invoice_object.line_items[2].tax_and_discount_polies.size).to eq(2)
      expect(invoice_object.line_items[2].tax_and_discount_polies.first).to have_attributes({
                                                                                              'name' => 'CGST',
                                                                                              'amount' => 18.0,
                                                                                              'td_type' => 'tax'
                                                                                            })
      expect(invoice_object.line_items[2].tax_and_discount_polies.last).to have_attributes({
                                                                                             'name' => 'Sale',
                                                                                             'amount' => -10.0,
                                                                                             'td_type' => 'discount'
                                                                                           })
      # expect(invoice_object.tax_and_discount_polies.last.marked_for_destruction?).to be_truthy
      expect(invoice_object.line_items.first.changes).to eq({ 'item_name' => ['Consultation', 'Travel Service'], 'unit' => %w[pc hrs] })
    end
  end

  context 'when td is updated on one line item and the other line item is removed' do
    let(:invoice_params) do
      HashWithIndifferentAccess.new({
                                      'id' => invoice.id,
                                      'name' => 'invoice new',
                                      'due_date' => invoice.due_date,
                                      'payment_date' => invoice.payment_date,
                                      'line_items_attributes' => {
                                        consultation.id.to_s => {
                                          'item_name' => consultation.item_name,
                                          'quantity' => consultation.quantity,
                                          'unit_rate' => consultation.unit_rate,
                                          'unit' => consultation.unit,
                                          'tax_and_discount_ids' => [discount.id],
                                          'product_id' => consultation.product.id,
                                          'id' => consultation.id.to_s
                                        }
                                      },
                                      'tax_and_discount_polies_attributes' => {
                                        tax_policy.id => {
                                          'name' => 'New Tax',
                                          'amount' => tax.amount,
                                          'td_type' => tax.td_type,
                                          'tax_and_discount_id' => tax.id,
                                          'id' => tax_policy.id
                                        },
                                        discount_policy.id => {
                                          'name' => discount.name,
                                          'amount' => discount.amount,
                                          'td_type' => discount.td_type,
                                          'tax_and_discount_id' => discount.id,
                                          'id' => discount_policy.id
                                          # '_destroy' => true TODO: Yet to handle this deletion of invoice tds
                                        }
                                      },
                                      'note' => ''
                                    })
    end

    it 'updates the attributes' do
      invoice_object = described_class.new(invoice.id, invoice_params).call
      # expect(invoice_object.line_items.last.marked_for_destruction?).to be_truthy
      expect(invoice_object.line_items.first.tax_and_discount_polies.size).to eq(2)
      expect(invoice_object.line_items.first.tax_and_discount_polies.first.marked_for_destruction?).to be_truthy
      expect(invoice_object.line_items.first.tax_and_discount_polies.last.marked_for_destruction?).to be_falsey
    end
  end

  context 'removing the tax from line item when invoice tax is present' do # rubocop:disable RSpec/ContextWording
    let(:invoice_params) do
      HashWithIndifferentAccess.new({
                                      'id' => invoice.id,
                                      'name' => 'invoice new',
                                      'due_date' => invoice.due_date,
                                      'payment_date' => invoice.payment_date,
                                      'line_items_attributes' => {
                                        consultation.id.to_s => {
                                          'item_name' => consultation.item_name,
                                          'quantity' => consultation.quantity,
                                          'unit_rate' => consultation.unit_rate,
                                          'unit' => consultation.unit,
                                          'tax_and_discount_ids' => [],
                                          'product_id' => consultation.product.id,
                                          'id' => consultation.id.to_s
                                        },
                                        development.id.to_s => {
                                          'item_name' => development.item_name,
                                          'quantity' => development.quantity,
                                          'unit_rate' => development.unit_rate,
                                          'unit' => development.unit,
                                          'tax_and_discount_ids' => [tax.id],
                                          'product_id' => development.product.id,
                                          'id' => development.id.to_s
                                        }
                                      },
                                      'tax_and_discount_polies_attributes' => {
                                        tax_policy.id => {
                                          'name' => 'New Tax',
                                          'amount' => tax.amount,
                                          'td_type' => tax.td_type,
                                          'tax_and_discount_id' => tax.id,
                                          'id' => tax_policy.id
                                        },
                                        discount_policy.id => {
                                          'name' => discount.name,
                                          'amount' => discount.amount,
                                          'td_type' => discount.td_type,
                                          'tax_and_discount_id' => discount.id,
                                          'id' => discount_policy.id
                                        }
                                      },
                                      'note' => ''
                                    })
    end

    it 'updates the attributes' do
      invoice_object = described_class.new(invoice.id, invoice_params).call
      expect(invoice_object.line_items.first.tax_and_discount_polies.size).to eq(1)
      expect(invoice_object.line_items.first.tax_and_discount_polies.first.marked_for_destruction?).to be_truthy
      #expect(InvoiceAmountCalculator.new(invoice_object.line_items, invoice_object.tax_and_discount_polies).call).to eq([106.2, 100])
      invoice_object.save
      expect(invoice_object.total).to eq(106.2)
      expect(invoice_object.sub_total).to eq(100)
    end
  end
end
