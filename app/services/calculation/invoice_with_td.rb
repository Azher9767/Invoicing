module Calculation
  class InvoiceWithTd
    def initialize(line_items, invoice_tds)
      @line_items = line_items
      @itds = invoice_tds
      @tax_amount = 0
      @discount_amount = 0
    end

    def call
      @discount_amount = discounts.map { |itd| line_items_total * itd.amount / 100 }.sum if discounts.present?

      @total = line_items_total + @discount_amount

      @tax_amount = taxes.map { |itd| @total * itd.amount / 100 }.sum if taxes.present?

      @total += @tax_amount
      [@total, line_items_total, [@tax_amount, @discount_amount]]
    end

    private

    attr_reader :line_items, :itds

    def line_items_total
      @line_items_total ||= line_items.sum(&:total)
    end

    def discounts
      itds.select { |itd| itd.discount? }
    end

    def taxes
      itds.select { |itd| itd.tax? }
    end
  end
end
