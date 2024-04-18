class InvoiceAmountCalculator
  def calculate_sub_total(line_items, tax_and_discount_poly)
    line_items_total = line_items.sum(&:total)
    td_poly_total = tax_and_discount_poly.sum(&:td_amount_subtotal)

    line_items_total + td_poly_total
  end
end

