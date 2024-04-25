class TaxAndDiscount < ApplicationRecord
  belongs_to :user
  has_many :tax_and_discount_polies, as: :tax_discountable
  validates :name, :amount, :td_type, presence: true

  include TaxAndDiscountQueries
end
