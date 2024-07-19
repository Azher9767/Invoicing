FactoryBot.define do
  factory :category do
    name { 'Electronic' }

    trait :user do
      user
    end
  end
end
