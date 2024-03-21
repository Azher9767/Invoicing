json.extract! product, :id, :name, :description, :unit_rate, :category_id, :unit, :created_at, :updated_at
json.url product_url(product, format: :json)
