module InvoicesHelper
  def categories(invoice)
    selected = invoice.line_items.map { |line_item| line_item.item_name }
    return [] unless @categories
    
    @categories.map do |category|
      [category.name, category.products.map { |product| [product.name, product.id, { selected: selected.include?(product.name) }] }]
    end
  end

  def td_options(current_user, object)
    selected = object.tax_and_discount_polies.map(&:tax_and_discount_id)
    selected_ids = object.tax_and_discount_polies.map { |tdp| { id: tdp.tax_and_discount_id, name: tdp.name, p_id: tdp.id }}

    tds = current_user.tax_and_discounts
    [
      ['Taxes', tds.tax.map { |t| [t.name, t.id, { selected: selected.include?(t.id), data: { poly_id: selected_ids.select {|td| td[:id] == t.id }} }] }],
      ['Discount', tds.discount.map { |d| [d.name, d.id, { selected: selected.include?(d.id), data: { poly_id: selected_ids.select {|td| td[:id] == d.id }} }] }]
    ]
  end
end
