module TaxAndDiscountQueries
  extend ActiveSupport::Concern

  TAX = 'tax'
  DISCOUNT = 'discount'

  included do
    enum td_type: {tax: TAX, discount: DISCOUNT}
  end
  
  def tax?
    amount > 0
  end

  def discount?
    amount < 0
  end
end
