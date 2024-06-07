module Calculation
  class InvoiceTaxCalculator
    def initialize(tax, line_items,  sub_total, invoice_discounts)
      @tax = tax
      @line_items = line_items
      @sub_total = sub_total
      @invoice_discounts = invoice_discounts
    end

    def call
      return plain_tax if plain_line_items?
      return 0.0 if discounted_line_items.blank?

      handle_discounted_line_items
    end

    attr_reader :tax, :line_items, :sub_total, :invoice_discounts

    def plain_tax
      sub_total * 0.01 * tax.amount
    end

    def plain_line_items?
      line_items.none? do |li|
        li.tax_and_discount_polies.any?
      end
    end

    def discounted_line_items
      @discounted_line_items ||= line_items.select do |li|
        next if li.tax_and_discount_polies.any?(&:tax?)

        li.tax_and_discount_polies.blank? || li.tax_and_discount_polies.any?(&:discount?)
      end
    end

    def handle_discounted_line_items
      discounted_line_items.inject(0.0) do |acc, li|
        total_discount_percentage = li.tax_and_discount_polies.select { |td| td.discount? }.sum(&:amount)
        discounted_basic_rate = (li.total * 0.01 * total_discount_percentage) + li.total
        discounted = invoice_discounts.inject(0.0) do |sum, disc|
          discounted_basic_rate.round(2) + (discounted_basic_rate * 0.01 * disc.amount).round(2) + sum
        end
        discounted = discounted_basic_rate if discounted.zero?
        (discounted * 0.01 * tax.amount) + acc
      end
    end
  end
end
