FactoryBot.define do
  factory :line_item do
    item_name { 'Computer work' }
    unit_rate { 100.0 }
    quantity { 1.0 }
  end
end
