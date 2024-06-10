module InvoicesHelper
  def categories(invoice)
    selected = invoice.line_items.map { |line_item| line_item.item_name }
    return [] unless @categories
    
    @categories.map do |category|
      [category.name, category.products.map { |product| [product.name, product.id, { selected: selected.include?(product.name) }] }]
    end
  end

  def td_options(current_user, invoice)
    selected = invoice.tax_and_discount_polies.map { |tdp| tdp.name }
    tds = current_user.tax_and_discounts
    [
      ["Taxes", tds.tax.map{|t| [t.name, t.id, { selected: selected.include?(t.name) }]}],
      ["Discount", tds.discount.map{|d| [d.name, d.id, { selected: selected.include?(d.name) }]}]
    ]
  end
end
