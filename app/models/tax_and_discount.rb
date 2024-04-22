class TaxAndDiscount < ApplicationRecord
  belongs_to :user
  has_many :tax_and_discount_polies, as: :tax_discountable

  include TaxAndDiscountValidations
end
