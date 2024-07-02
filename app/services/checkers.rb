# frozen_string_literal: true

# This module is used to check the presence of tax and discount polies
# in line items and invoice tax calculation classes
module Checkers
  def only_line_items?
    !td_in_line_items_only? && !td_on_invoice_only?
  end

  def td_in_line_items_and_invoice?
    any_line_item_with_tds? && @itds.any?
  end

  # Line items with tax and discount polies but none of those tds are marked for destruction
  def any_line_item_with_tds?
    @line_items.any? { |line_item| line_item.tax_and_discount_polies.reject(&:marked_for_destruction?).present? }
  end

  alias td_in_line_items_only? any_line_item_with_tds?

  def td_on_invoice_only?
    @itds.any? && !any_line_item_with_tds?
  end
end
