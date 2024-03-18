json.extract! line_item, :id, :item_name, :unit_rate, :quantity, :receipt_id, :product_id, :unit, :vendor_currency, :vendor_amount, :meta, :created_at, :updated_at
json.url line_item_url(line_item, format: :json)
