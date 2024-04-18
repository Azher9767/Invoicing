class TaxAndDiscount < ApplicationRecord
  belongs_to :user
  has_many :tax_and_discount_polies, as: :tax_discountable

  TAX = 'tax'
  DISCOUNT = 'discount'
  enum td_type: {tax: TAX, discount: DISCOUNT}
end
