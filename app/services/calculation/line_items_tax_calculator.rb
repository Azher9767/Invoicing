module Calculation
  class LineItemsTaxCalculator
    def initialize(line_item, invoice_discounts)
      @line_item = line_item
      @invoice_discounts = invoice_discounts
    end

    def call
      taxes * 0.01 * discounted_basic_rate
    end

    private

    attr_reader :line_item, :invoice_discounts

    delegate :total, to: :line_item, prefix: true

    def discounted_basic_rate
      if invoice_discounts.present?
        handle_with_invoice_discounts
      else
        line_item_discounted_basic_rate
      end
    end

    def handle_with_invoice_discounts
      invoice_discounts.inject(0.0) do |total, discount|
        amount = discount.amount * 0.01 * line_item_discounted_basic_rate
        amount + line_item_discounted_basic_rate + total
      end
    end

    def taxes
      policies.select(&:tax?).sum(&:amount)
    end

    def line_item_discounted_basic_rate
      (line_item_total * 0.01 * total_discount_percentage) + line_item_total
    end

    def total_discount_percentage
      policies.select(&:discount?).sum(&:amount)
    end

    def policies
      @policies ||= line_item.tax_and_discount_polies.reject(&:marked_for_destruction?)
    end
  end
end
