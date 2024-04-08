module InvoicesHelper
  def categories
    @categories.map do |category|
      [category.name, category.products.map { |product| [product.name, product.id] }]
    end
  end
end
