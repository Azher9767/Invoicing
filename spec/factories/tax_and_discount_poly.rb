FactoryBot.define do
  factory :tax_and_discount_poly do
    amount { 0.0 }
    name { 'GST' }
    td_type { 'tax' }
  end
end
