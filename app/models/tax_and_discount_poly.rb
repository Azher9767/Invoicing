class TaxAndDiscountPoly < ApplicationRecord
  belongs_to :tax_discountable, polymorphic: true
  
  def tax?
    amount > 0
  end

  def discount?
    amount < 0
  end
end
