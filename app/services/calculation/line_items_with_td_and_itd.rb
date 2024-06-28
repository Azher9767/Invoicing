# frozen_string_literal: true

module Calculation
  # 1. calculate subtotal >> consider line items discount
  # 2. calculate total >> apply invoice discount on subtotal
  # 3. apply invoice tax on untaxed line items
  # 4. apply invoice discount on taxed and untaxed line items
  # 5. apply line items tax after invoice tds
  LineItemsWithTdAndItd = Struct.new :invoice
  class LineItemsWithTdAndItd
    def initialize(line_items, invoice_tds)
      @line_items = line_items
      @invoice_tds = invoice_tds
    end

    def call
      [
        total.round(2),
        sub_total,
        [0.0, 0.0]
      ]
    end

    private

    attr_reader :line_items, :invoice_tds

    def sub_total
      @sub_total ||= line_items.sum do |li|
        apply_polies(li.total, li.discounts)
      end
    end

    def apply_polies(amount, policies)
      policies.reduce(amount) do |current_amount, td|
        if td.discount? && !td.marked_for_destruction?
          current_amount += current_amount * td.amount / 100.0
          current_amount
        else
          amount
        end
      end
    end

    def total
      new_subtotal = sub_total + invoice_discount(sub_total)
      new_subtotal = new_subtotal + line_items_tax
      new_subtotal + invoice_tax(new_subtotal)
    end

    def invoice_discount(total_amount)
      disc_amount = 0.0
      amount = total_amount

      invoice_tds.select(&:discount?).each do |td|
        disc_amount += (td.amount / 100) * amount
        amount = amount + disc_amount
      end

      disc_amount
    end

    def line_items_tax
      line_items.reduce(0.0) do |total, line_item|
        LineItemsTaxCalculator.new(line_item, invoice_discounts).call + total
      end
    end

    def invoice_tax(new_subtotal)
      invoice_taxes.reduce(0.0) do |total, tax|
        InvoiceTaxCalculator.new(tax, line_items, new_subtotal, invoice_discounts).call + total
      end
    end

    def invoice_taxes
      invoice_tds.select(&:tax?)
    end

    def invoice_discounts
      invoice_tds.select(&:discount?)
    end
  end
end
