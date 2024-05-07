class LineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :product, optional: true
  validates :item_name,  presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  def total
    quantity * unit_rate
  end
end
