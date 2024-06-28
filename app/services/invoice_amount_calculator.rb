class InvoiceAmountCalculator
  include Checkers

  def initialize(line_items, invoice_tds)
    @line_items = line_items
    @itds = invoice_tds
  end

  def call # rubocop:disable Metrics/MethodLength
    if only_line_items?
      [@line_items.sum(&:total), @line_items.sum(&:total)]
    else
      if td_in_line_items_and_invoice?
        Calculation::LineItemsWithTdAndItd.new(@line_items, @itds).call
      elsif td_in_line_items_only?
        Calculation::LineItemsWithTd.new(@line_items).call
      elsif td_on_invoice_only?
        Calculation::InvoiceWithTd.new(@line_items, @itds).call
      end
    end
  end
end
