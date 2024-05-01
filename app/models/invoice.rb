class Invoice < ApplicationRecord
  belongs_to :user
  has_many :tax_and_discount_polies, as: :tax_discountable, dependent: :destroy

  DRAFT = 'draft'
  PENDING = 'pending'
  PAID = 'paid'
  enum status: { draft: DRAFT, pending: PENDING, paid: PAID }

  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :name, presence: true
  validates :line_items, presence: true
  validates :tax_and_discount_polies, presence: true
  
  has_many :line_items, dependent: :destroy

  accepts_nested_attributes_for :line_items
  
  has_many :tax_and_discounts

  accepts_nested_attributes_for :tax_and_discount_polies

  before_save :calculate_sub_total

  private

  def calculate_sub_total
    self.total, self.sub_total = InvoiceAmountCalculator.new.calculate_sub_total(line_items, tax_and_discount_polies)
  end
end
