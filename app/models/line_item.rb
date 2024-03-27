class LineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :product, optional: true

  def total
    quantity * unit_rate
  end
end
