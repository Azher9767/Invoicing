module TaxAndDiscountValidations
  extend ActiveSupport::Concern
  
  FIXED = 'fixed'
  PERCENTAGE = 'percentage'
  TAX = 'tax'
  DISCOUNT = 'discount'

  included do
    enum tax_type: { percentage: PERCENTAGE, fixed: FIXED }
    enum td_type: {tax: TAX, discount: DISCOUNT}
  end

  def tax?
    amount > 0
  end

  def discount?
    amount < 0
  end
end
