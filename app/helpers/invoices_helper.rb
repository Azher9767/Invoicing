module InvoicesHelper
  def categories
    @categories.map do |category|
      [category.name, category.products.map { |product| [product.name, product.id] }]
    end
  end

  def td_options
    [
      ["Taxes", TaxAndDiscount.tax_type],
      ["Discount", TaxAndDiscount.discount_type]
    ]
  end
end
