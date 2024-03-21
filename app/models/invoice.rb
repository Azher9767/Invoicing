class Invoice < ApplicationRecord
  belongs_to :user

  DRAFT = 'draft'
  PENDING = 'pending'
  PAID = 'paid'
  enum status: { draft: DRAFT, pending: PENDING, paid: PAID }

  validates :status, presence: true, inclusion: { in: statuses.keys }

  accepts_nested_attributes_for :line_items
end
