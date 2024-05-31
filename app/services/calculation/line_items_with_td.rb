module Calculation
  # This class calculates invoice's total and sub total when it has line items with taxes or discounts or both and no invoice taxes or discounts
  class LineItemsWithTd
    def initialize(line_items)
      @line_items = line_items
    end

    def call
      [
        total,
        sub_total
      ]
    end

    private

    attr_reader :line_items

    def sub_total
      @sub_total ||= line_items.sum do |li|
        apply_discounts(li)
      end
    end

    def total
      @total ||= line_items.sum do |li|
        discounted_amount = apply_discounts(li)
        apply_taxes(li, discounted_amount)
      end
    end

    def apply_discounts(line_item)
      line_item.tax_and_discount_polies.reduce(line_item.total) do |amount, td|
        if td.discount?
          amount += line_item.total * td.amount / 100
        end
        amount
      end
    end

    def apply_taxes(line_item, discounted_amount)
      line_item.tax_and_discount_polies.reduce(discounted_amount) do |amount, td|
        if td.tax?
          amount += discounted_amount * td.amount / 100
        end
        amount
      end
    end
  end
end
