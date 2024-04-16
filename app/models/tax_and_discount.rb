class TaxAndDiscount < ApplicationRecord
  belongs_to :user
  belongs_to :invoice

  TAX = 'tax'
  DISCOUNT = 'discount'
  enum td_type: {tax: TAX, discount: DISCOUNT}
end
