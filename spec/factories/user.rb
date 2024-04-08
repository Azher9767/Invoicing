FactoryBot.define do
  factory :user do
    email { "azher@gmail.com" }
    password  { "azher@123" }
    password_confirmation { "azher@123" }
  end
end
