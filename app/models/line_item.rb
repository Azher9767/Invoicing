class LineItem < ApplicationRecord
  belongs_to :invoice
  # belongs_to :product
  has_many :products
end
