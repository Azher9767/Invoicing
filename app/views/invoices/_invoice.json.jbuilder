json.extract! invoice, :id, :user_id, :line_items_count, :name, :status, :sub_total, :note, :payment_date, :due_date, :created_at, :updated_at
json.url invoice_url(invoice, format: :json)
