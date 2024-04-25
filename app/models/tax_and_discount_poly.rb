class TaxAndDiscountPoly < ApplicationRecord
  belongs_to :tax_discountable, polymorphic: true

 include TaxAndDiscountQueries
end
