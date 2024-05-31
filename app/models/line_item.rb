class LineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :product, optional: true
  validates :item_name,  presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  has_many :tax_and_discount_polies, as: :tax_discountable
  has_many :tax_and_discounts, through: :tax_and_discount_polies, source: :tax_and_discount
  accepts_nested_attributes_for :tax_and_discount_polies

  def total
    quantity * unit_rate
  end

  def discounts
    tax_and_discount_polies.select(&:discount?)
  end

  def taxes
    tax_and_discount_polies.select(&:tax?)
  end
end
