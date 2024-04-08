FactoryBot.define do
  factory :user do
    email { "johndoe@example.com" }
    password  { "password" }
    password_confirmation { "password" }
  end
end
