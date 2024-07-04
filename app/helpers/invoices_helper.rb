# frozen_string_literal: true
module InvoicesHelper
  def categories(invoice)
    selected = invoice.line_items.map(&:item_name)
    return [] unless @categories

    @categories.map do |category|
      [category.name, category.products.map { |product| [product.name, product.id, { selected: selected.include?(product.name) }] }]
    end
  end

  def td_options(current_user, object)
    selected = object.tax_and_discount_polies.map(&:tax_and_discount_id)
    selected_ids = object.tax_and_discount_polies.map { |tdp| { id: tdp.tax_and_discount_id, name: tdp.name, p_id: tdp.id } }
    tds = current_user.tax_and_discounts
    [
      ['Taxes', td_option(tds.tax, selected, selected_ids)],
      ['Discount', td_option(tds.discount, selected, selected_ids)]
    ]
  end

  def td_option(tds, selected, selected_ids)
    tds.map do |td|
      [
        td.name,
        td.id,
        {
          selected: selected.include?(td.id), 
          data: { poly_id: selected_ids.select { |poly| poly[:id] == td.id } }
        }
      ]
    end
  end
end
