class LineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :product, optional: true
end
