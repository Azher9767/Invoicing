module Calculation
  class InvoiceWithTd
    def initialize(line_items, invoice_tds)
      @line_items = line_items
      @itds = invoice_tds
      @tax_amount = 0
      @discount_amount = 0
    end

    def call
      @discount_amount = calculate_invoice_discounts

      @total = line_items_total + @discount_amount

      @tax_amount = taxes.sum { |itd| @total * itd.amount / 100 } if taxes.present?

      @total += @tax_amount
      [@total.round(2), line_items_total, [@tax_amount.round(2), @discount_amount]]
    end

    private

    attr_reader :line_items, :itds

    def calculate_invoice_discounts
      disc_amount = 0.0
      amount = line_items_total

      itds.select(&:discount?).each do |td|
        disc_amount += (td.amount / 100) * amount
        amount += disc_amount
      end

      disc_amount
    end

    def line_items_total
      @line_items_total ||= line_items.sum(&:total)
    end

    def discounts
      itds.select(&:discount?)
    end

    def taxes
      itds.select(&:tax?)
    end
  end
end
