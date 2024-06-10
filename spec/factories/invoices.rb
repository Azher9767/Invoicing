FactoryBot.define do
  factory :invoice do
    name { 'Sales invoice' }
    status { 'pending' }
    due_date { Date.today + 10.days }
    note { 'This is a sales invoice' }

    trait :paid do
      status { 'paid' }
      payment_date { Date.today }
    end

    trait :draft do
      status { 'draft' }
    end
  end
end
