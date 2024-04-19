class TaxAndDiscountPoly < ApplicationRecord
  belongs_to :tax_discountable, polymorphic: true

  FIXED = 'fixed'
  PERCENTAGE = 'percentage'
  enum tax_type: {fixed: FIXED, percentage: PERCENTAGE}

  TAX = 'tax'
  DISCOUNT = 'discount'
  enum td_type: {tax: TAX, discount: DISCOUNT}
  
  def tax?
    amount > 0
  end

  def discount?
    amount < 0
  end
end
