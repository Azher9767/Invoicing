RSpec.describe InvoiceObjectBuilder do
  describe "when we tax_and_discount_polies for line_item" do
    let(:invoice_params) do
      HashWithIndifferentAccess.new({
        "name"=>"July Invoice",
        "status"=>"draft",
        "due_date"=>"2024-05-31",
        "payment_date"=>"",
        "line_items_attributes"=>{
          "1158834445767833475"=>{
            "item_name"=>"Ruby Work",
            "quantity"=>"1",
            "unit_rate"=>"100.0",
            "unit"=>"",
            "tax_and_discount_polies_attributes"=>{
              "0"=>{
                "tax_and_discount_id"=>["1"]
              }
            },
            "product_id"=>"1",
            "id"=>""
          },
          "1417777177487328085"=>{
            "item_name"=>"Rails Work",
            "quantity"=>"2",
            "unit_rate"=>"200.0",
            "unit"=>"",
            "tax_and_discount_polies_attributes"=>{
              "1"=>{
                "tax_and_discount_id"=>["3"]
              }
            },
            "product_id"=>"1",
            "id"=>""
          }
        },
        "tax_and_discount_polies_attributes"=>{
          "1549552995293543201"=>{
            "name"=>"Shipping charges",
            "amount"=>"10.0",
            "td_type"=>"tax",
            "tax_and_discount_id"=>"1",
            "id"=>""
          }
        },
        "note"=>""
      })
    end
  
    let(:tax_and_discount) { build(:tax_and_discount, id: 1) }
  
    before do
      allow(TaxAndDiscount).to receive(:where).and_return([tax_and_discount])
    end

    it "returns an invoice object" do
      invoice_object = InvoiceObjectBuilder.new(invoice_params).call
      expect(invoice_object).to be_a(Invoice)
    end

    it "builds the invoice object with line items and tax and discount polies" do
      invoice_object = InvoiceObjectBuilder.new(invoice_params).call
      expect(invoice_object.line_items.first.tax_and_discount_polies.first).to have_attributes(
        name: "GST",
        amount: 18.0,
        td_type: "tax"
      )
    end
  end

  describe "when we do not have tax_and_discount_polies for line_item" do
    let(:invoice_params) do
      HashWithIndifferentAccess.new({
        "name"=>"July Invoice",
        "status"=>"draft",
        "due_date"=>"2024-05-31",
        "payment_date"=>"",
        "line_items_attributes"=>{
          "1158834445767833475"=>{
            "item_name"=>"Ruby Work",
            "quantity"=>"1",
            "unit_rate"=>"100.0",
            "unit"=>"",
            "tax_and_discount_polies_attributes"=>{
              "0"=>{
                "tax_and_discount_id"=>[""]
              }
            },
            "product_id"=>"1",
            "id"=>""
          }
        },
        "tax_and_discount_polies_attributes"=>{
          "1549552995293543201"=>{
            "name"=>"Shipping charges",
            "amount"=>"10.0",
            "td_type"=>"tax",
            "tax_and_discount_id"=>"1",
            "id"=>""
          }
        },
        "note"=>""
      })
    end

    it "returns an invoice object" do
      invoice_object = InvoiceObjectBuilder.new(invoice_params).call
      expect(invoice_object).to be_a(Invoice)
    end

    it "builds the invoice object with line items and no tax and discount polies" do
      invoice_object = InvoiceObjectBuilder.new(invoice_params).call
      expect(invoice_object.line_items.first.tax_and_discount_polies).to eq([])
    end
  end
end
