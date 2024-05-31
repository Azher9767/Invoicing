FactoryBot.define do
  factory :tax_and_discount_poly do
    trait :discount do
      amount { -10.0 }
      name { 'New Year Discount' }
      td_type { 'discount' }
    end

    trait :tax do
      amount { 18.0 }
      name { 'GST' }
      td_type { 'tax' }
    end
  end
end
