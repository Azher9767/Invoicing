class TaxAndDiscountPoly < ApplicationRecord
  belongs_to :tax_discountable, polymorphic: true

  include TaxAndDiscountValidations
end
