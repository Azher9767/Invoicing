module Calculation
  # This class calculates invoice's total and sub total when it has line items with taxes or discounts or both and no invoice taxes or discounts
  class LineItemsWithTd
    include LineItemsQueries

    def initialize(line_items)
      @line_items = line_items
    end

    def call
      [
        total.round(2),
        sub_total,
        [taxable_amount, discountable_amount]
      ]
    end

    private

    attr_reader :line_items

    def sub_total
      @sub_total ||= line_items_polies.sum do |li|
        apply_discounts(li)
      end
    end

    def total
      @total ||= line_items_polies.sum do |li|
        discounted_amount = apply_discounts(li)
        apply_taxes(li, discounted_amount)
      end
    end

    def apply_discounts(line_item)
      line_item.tax_and_discount_polies.reduce(line_item.total) do |amount, td|
        if td.discount? && !td.marked_for_destruction?
          amount += line_item.total * td.amount / 100
        end
        amount
      end
    end

    def apply_taxes(line_item, discounted_amount)
      line_item.tax_and_discount_polies.reduce(discounted_amount) do |amount, td|
        if td.tax? && !td.marked_for_destruction?
          amount += discounted_amount * td.amount / 100
        end
        amount
      end
    end

    def taxable_amount
      @taxable_amount ||= line_items_polies.sum do |li|
        li.tax_and_discount_polies.select(&:tax?).sum do |td|
          apply_discounts(li) * td.amount / 100
        end
      end
    end

    def discountable_amount
      @discountable_amount ||= line_items_polies.sum do |li|
        li.tax_and_discount_polies.select(&:discount?).sum do |td|
          li.total * td.amount / 100
        end
      end
    end
  end
end
