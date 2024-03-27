class InvoiceAmountCalculator
  def calculate_sub_total(line_items)
    line_items.sum(&:total)
  end
end
