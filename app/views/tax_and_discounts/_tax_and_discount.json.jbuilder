json.extract! tax_and_discount, :id, :name, :description, :td_type, :amount, :belongs_to, :user, :created_at, :updated_at
json.url tax_and_discount_url(tax_and_discount, format: :json)
