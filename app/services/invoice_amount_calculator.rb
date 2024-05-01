class InvoiceAmountCalculator
  def calculate_sub_total(line_items, tax_and_discount_polys)
    if line_items.present?
      line_items_total = line_items.sum(&:total)
      tax_total = 0
      discount_total = 0
      tax_and_discount_polys.each do |td_poly|
        if td_poly.tax?
          tax_total += line_items_total * (td_poly.amount / 100.0)
        elsif td_poly.discount?
          discount_total += line_items_total * (td_poly.amount / 100.0)
        end
      end

      total = line_items_total + tax_total + discount_total
      sub_total = line_items_total
      tax_or_discount = [tax_total, discount_total ]
      [total, sub_total, tax_or_discount]
    else
      0.0
    end
  end
end
