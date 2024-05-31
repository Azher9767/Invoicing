module Checkers
  def only_line_items?
    !td_in_line_items_only? && !td_on_invoice_only? 
  end

  def td_in_line_items_and_invoice?
    any_line_item_with_tds? && @itds.any?
  end

  def any_line_item_with_tds?
    @line_items.any? { |line_item| line_item.tax_and_discount_polies.present? }
  end

  alias_method :td_in_line_items_only?, :any_line_item_with_tds?

  def td_on_invoice_only?
    @itds.any? && !any_line_item_with_tds?
  end
end
