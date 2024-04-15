class TaxAndDiscount < ApplicationRecord
  belongs_to :user
  has_many :invoices

  def self.tax_type
    where("amount > 0").pluck(:name)
  end

  def self.discount_type
    where("amount <= 0").pluck(:name)
  end
end
