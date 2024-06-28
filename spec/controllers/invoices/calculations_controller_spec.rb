RSpec.describe Invoices::CalculationsController do
  subject(:create_request) do
    response = post :create, params: params, format: 'turbo_stream'
    expect(response).to have_http_status(:ok) # rubocop:disable RSpec/PredicateMatcher
    response
  end

  let(:current_user) { create(:user) }
  let(:line_item) { build(:line_item) }
  let(:tax_and_discount_poly) { build(:tax_and_discount_poly, :tax) }

  let(:line_item_attributes) do
    {
      'quantity' => '1',
      'unitRate' => '100',
      'unit' => 'hrs',
      'tdIds' => []
    }
  end

  let(:tax_and_discount_poly_attributes) do
    [
      {
        'amount' => '10',
        'td_type' => 'tax',
        'name' => 'GST'
      }
    ]
  end

  let(:params) do
    {
      'calculation' => {
        'lineItemsAttributes' => [line_item_attributes],
        'taxAndDiscountPolyAttributes' => tax_and_discount_poly_attributes
      }
    }
  end

  context 'with invoice tax/discount' do
    context 'when invoice tax is present' do
      it 'returns the invoice tax amount' do
        create_request
  
        expect(assigns(:total)).to eq(110.0)
        expect(assigns(:sub_total)).to eq(100.0)
        expect(assigns(:tax_or_discount)).to eq([10.0, 0.0])
      end
    end

    context 'when invoice discount is present' do
      let(:tax_and_discount_poly_attributes) do
        [
          {
            'amount' => '-10',
            'td_type' => 'discount',
            'name' => 'diwali sale'
          }
        ]
      end

      it 'return invoice discount amount' do
        post :create, params: params, format: 'turbo_stream'

        expect(assigns(:total)).to eq(90.0)
        expect(assigns(:sub_total)).to eq(100.0)
        expect(assigns(:tax_or_discount)).to eq([0.0, -10.0])
      end
    end
  end

  context 'with multiple line item tds' do
    context 'when line items have multiple taxes' do
      let(:td_first) do
        create(:tax_and_discount, id: 3, amount: 5, td_type: 'tax', user: current_user)
      end
  
      let(:td_second) do
        create(:tax_and_discount, id: 4, amount: 10, td_type: 'tax', user: current_user)
      end
  
      let(:line_item_attributes) do
        {
          'quantity' => '1',
          'unitRate' => '100',
          'unit' => 'hrs',
          'tdIds' => [td_first.id, td_second.id]
        }
      end
  
      let(:tax_and_discount_poly_attributes) { [] }

      it 'return line item tax amount' do
        create_request
        expect(assigns(:total)).to eq(115.0)
        expect(assigns(:sub_total)).to eq(100.0)
        expect(assigns(:tax_or_discount)).to eq([0.0, 0.0])
      end
    end

    context 'when line items have multiple discounts' do
      let(:td_first) do
        create(:tax_and_discount, id: 3, amount: -10, td_type: 'discount', user: current_user)
      end
  
      let(:td_second) do
        create(:tax_and_discount, id: 4, amount: -5, td_type: 'discount', user: current_user)
      end

      let(:line_item_attributes) do
        {
          'quantity' => '1',
          'unitRate' => '100',
          'unit' => 'hrs',
          'tdIds' => [td_first.id, td_second.id]
        }
      end
  
      let(:tax_and_discount_poly_attributes) { [] }
  
      let(:params) do
        {
          'calculation' => {
            'lineItemsAttributes' => [line_item_attributes],
            'taxAndDiscountPolyAttributes' => tax_and_discount_poly_attributes
          }
        }
      end
  
      it 'retrun line item discount amount' do
        post :create, params: params, format: 'turbo_stream'
        expect(assigns(:total)).to eq(85.0)
        expect(assigns(:sub_total)).to eq(85.0)
        expect(assigns(:tax_or_discount)).to eq([0.0, 0.0])
      end
    end

    context 'when line items have a combination of tax and discount' do
      let(:td_first) do
        create(:tax_and_discount, id: 3, amount: -5, td_type: 'discount', user: current_user)
      end
  
      let(:td_second) do
        create(:tax_and_discount, id: 4, amount: 10, td_type: 'tax', user: current_user)
      end
  
      let(:line_item_attributes) do
        {
          'quantity' => '1',
          'unitRate' => '100',
          'unit' => 'hrs',
          'tdIds' => [td_first.id, td_second.id]
        }
      end
  
      let(:tax_and_discount_poly_attributes) { [] }
  
      let(:params) do
        {
          'calculation' => {
            'lineItemsAttributes' => [line_item_attributes],
            'taxAndDiscountPolyAttributes' => tax_and_discount_poly_attributes
          }
        }
      end
  
      it 'return line item tax and discount amount' do
        post :create, params: params, format: 'turbo_stream'
        expect(assigns(:total)).to eq(104.5)
        expect(assigns(:sub_total)).to eq(95.0)
        expect(assigns(:tax_or_discount)).to eq([0.0, 0.0])
      end
    end
  end

  context 'with multiple invoice tds' do
    context 'when invoice have multiple taxes' do
      let(:tax_and_discount_poly_attributes) do
        [
          {
            'amount' => '10',
            'td_type' => 'tax',
            'name' => 'Sales tax'
          },
          {
            'amount' => '5',
            'td_type' => 'tax',
            'name' => 'GST'
          }
        ]
      end

      let(:params) do
        {
          'calculation' => {
            'lineItemsAttributes' => [line_item_attributes],
            'taxAndDiscountPolyAttributes' => tax_and_discount_poly_attributes
          }
        }
      end

      it 'return the invoice tax amount' do
        post :create, params: params, format: 'turbo_stream'

        expect(assigns(:total)).to eq(115.0)
        expect(assigns(:sub_total)).to eq(100.0)
        expect(assigns(:tax_or_discount)).to eq([15.0, 0.0])

      end
    end

    context 'when invoice have multiple discouts' do
      let(:tax_and_discount_poly_attributes) do
        [
          {
            'amount' => '-10',
            'td_type' => 'discount',
            'name' => 'New Year Sale'
          },
          {
            'amount' => '-5',
            'td_type' => 'discount',
            'name' => 'Diwali sale'
          }
        ]
      end

      let(:params) do
        {
          'calculation' => {
            'lineItemsAttributes' => [line_item_attributes],
            'taxAndDiscountPolyAttributes' => tax_and_discount_poly_attributes
          }
        }
      end

      it 'return the invoice discount amount' do
        post :create, params: params, format: 'turbo_stream'

        expect(assigns(:total)).to eq(85.5)
        expect(assigns(:sub_total)).to eq(100.0)
        expect(assigns(:tax_or_discount)).to eq([0.0, -14.5])

      end
    end

    context 'when invoice have a combination of tax and discount' do

      let(:tax_and_discount_poly_attributes) do
        [
          {
            'amount' => '-10',
            'td_type' => 'discount',
            'name' => 'New Year Sale'
          },
          {
            'amount' => '5',
            'td_type' => 'tax',
            'name' => 'Diwali sale'
          }
        ]
      end

      let(:params) do
        {
          'calculation' => {
            'lineItemsAttributes' => [line_item_attributes],
            'taxAndDiscountPolyAttributes' => tax_and_discount_poly_attributes
          }
        }
      end

      it 'return the invoice tax and discount amount' do
        post :create, params: params, format: 'turbo_stream'

        expect(assigns(:total)).to eq(94.50)
        expect(assigns(:sub_total)).to eq(100.0)
        expect(assigns(:tax_or_discount)).to eq([4.5, -10.0])
      end
    end
  end

  context 'with multiple line item tds and invoice tds' do
    context 'when line items have multiple taxes' do
      let(:td_tax_one) do
        create(:tax_and_discount, :tax, amount: 5, user: current_user)
      end
  
      let(:td_tax_two) do
        create(:tax_and_discount, :tax, amount: 10, user: current_user)
      end
  
      let(:line_item_attributes) do
        [
          {
            'quantity' => '1',
            'unitRate' => '100',
            'unit' => 'hrs',
            'tdIds' => [td_tax_one.id]
          },
          {
            'quantity' => '1',
            'unitRate' => '100',
            'unit' => 'hrs',
            'tdIds' => [td_tax_two.id]
          },
          {
            'quantity' => '1',
            'unitRate' => '100',
            'unit' => 'hrs',
            'tdIds' => []
          }
        ]
      end
  
      let(:tax_and_discount_poly_attributes) do
        [
          {
            'amount' => '10',
            'td_type' => 'tax',
            'name' => 'SGST'
          },
          {
            'amount' => '5',
            'td_type' => 'tax',
            'name' => 'CGST'
          }
        ]
      end
  
      let(:params) do
        {
          'calculation' => {
            'lineItemsAttributes' => line_item_attributes,
            'taxAndDiscountPolyAttributes' => tax_and_discount_poly_attributes
          }
        }
      end
  
      it 'return the invoice tax amount' do
        post :create, params: params, format: 'turbo_stream'

        expect(assigns(:total)).to eq(330.0)
        expect(assigns(:sub_total)).to eq(300.0)
        expect(assigns(:tax_or_discount)).to eq([0.0, 0.0])
      end
    end

    context 'when line items have multiple discouts' do
      let(:td_discount_one) do
        create(:tax_and_discount, :discount, amount: -5, user: current_user)
      end

      let(:td_discount_two) do
        create(:tax_and_discount, :discount, amount: -10, user: current_user)
      end

      let(:line_item_attributes) do
        [
          {
            'quantity' => '1',
            'unitRate' => '100',
            'unit' => 'hrs',
            'tdIds' => [td_discount_one.id]
          },
          {
            'quantity' => '1',
            'unitRate' => '100',
            'unit' => 'hrs',
            'tdIds' => [td_discount_two.id]
          },
          {
            'quantity' => '1',
            'unitRate' => '100',
            'unit' => 'hrs',
            'tdIds' => []
          }
        ]
      end

      let(:tax_and_discount_poly_attributes) do
        [
          {
            'amount' => '-10',
            'td_type' => 'discount',
            'name' => 'Diwali offer'
          },
          {
            'amount' => '-7',
            'td_type' => 'discount',
            'name' => 'new year sale'
          }
        ]
      end

      let(:params) do
        {
          'calculation' => {
            'lineItemsAttributes' => line_item_attributes,
            'taxAndDiscountPolyAttributes' => tax_and_discount_poly_attributes
          }
        }
      end

      it 'return the invoice discount amount' do
        post :create, params: params, format: 'turbo_stream'

        expect(assigns(:total)).to eq(238.55)
        expect(assigns(:sub_total)).to eq(285.0)
        expect(assigns(:tax_or_discount)).to eq([0.0, 0.0])
      end
    end

    context 'when line items have a combination of tax and discount' do
      let(:td_tax) do
        create(:tax_and_discount, :tax, amount: 5, user: current_user)
      end

      let(:td_discount) do
        create(:tax_and_discount, :discount, amount: -7, user: current_user)
      end

      let(:line_item_attributes) do
        [
          {
            'quantity' => '1',
            'unitRate' => '100',
            'unit' => 'hrs',
            'tdIds' => [td_tax.id]
          },
          {
            'quantity' => '1',
            'unitRate' => '100',
            'unit' => 'hrs',
            'tdIds' => [td_discount.id]
          },
          {
            'quantity' => '1',
            'unitRate' => '100',
            'unit' => 'hrs',
            'tdIds' => []
          }
        ]
      end

      let(:tax_and_discount_poly_attributes) do
        [
          {
            'amount' => '-5',
            'td_type' => 'discount',
            'name' => 'new year sales'
          },
          {
            'amount' => '10',
            'td_type' => 'tax',
            'name' => 'GST'
          }
        ]
      end

      let(:params) do
        {
          'calculation' => {
            'lineItemsAttributes' => line_item_attributes,
            'taxAndDiscountPolyAttributes' => tax_and_discount_poly_attributes
          }
        }
      end

      it 'rerturn invoice tax and discount amount' do
        post :create, params: params, format: 'turbo_stream'
        expect(assigns(:total)).to eq(301.44)
        expect(assigns(:sub_total)).to eq(293.0)
        expect(assigns(:tax_or_discount)).to eq([0.0, 0.0])
      end
    end
  end

  context 'total amount per line item' do # rubocop:disable RSpec/ContextWording
    let(:line_item_attributes) do
      {
        'quantity' => '1',
        'unitRate' => '100',
        'unit' => 'hrs',
        'objId' => '1',
        'tdIds' => []
      }
    end

    let(:tax_and_discount_poly_attributes) { [] }

    let(:params) do
      {
        'calculation' => {
          'lineItemsAttributes' => [line_item_attributes],
          'taxAndDiscountPolyAttributes' => tax_and_discount_poly_attributes
        }
      }
    end

    it 'return total amount per line item and their tds' do
      post :create, params: params, format: 'turbo_stream'
      expect(assigns(:line_item_details)).to eq({ '1' => { tax_and_discount_polies_attributes: [], total: 100.0 } })
      expect(assigns(:total)).to eq(100.0)
    end
  end
end
