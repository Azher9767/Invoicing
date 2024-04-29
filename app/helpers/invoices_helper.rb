module InvoicesHelper
  def categories
    return [] unless @categories
    
    @categories.map do |category|
      [category.name, category.products.map { |product| [product.name, product.id] }]
    end
  end

  def td_options(current_user)
    tds = current_user.tax_and_discounts
    [
      ["Taxes", tds.tax.map{|t| [t.name, t.id]}],
      ["Discount", tds.discount.map{|d| [d.name, d.id]}]
    ]
  end
end
