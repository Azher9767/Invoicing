class Product < ApplicationRecord
  belongs_to :category
  validates :name, presence: true
  validates :category_id, presence: true
end
