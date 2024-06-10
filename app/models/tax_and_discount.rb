class TaxAndDiscount < ApplicationRecord
  belongs_to :user
  has_many :tax_and_discount_polies, as: :tax_discountable
  validates :name, :amount, :td_type, presence: true

  # optional
  has_many :tax_and_discount_polies
  has_many :line_items, through: :tax_and_discount_polies, source: :tax_discountable, source_type: 'LineItem'

  include TaxAndDiscountQueries
end
