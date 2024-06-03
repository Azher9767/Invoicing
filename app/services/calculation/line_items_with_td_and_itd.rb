# frozen_string_literal: true

module Calculation
  # 1. calculate subtotal >> consider line items discount
  # 2. calculate total >> apply invoice discount on subtotal
  # 3. apply invoice tax on untaxed line items
  # 4. apply invoice discount on taxed and untaxed line items
  # 5. apply line items tax after invoice tds
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
        current_amount += current_amount * td.amount / 100.0
        current_amount
      end
    end

    def total
      if line_items_have_own_tax? && !line_items_have_own_discount? && invoice_tds.none?(&:discount?)
        calculate_total_without_discounts
      elsif line_items_have_own_tax? && !line_items_have_own_discount? && !invoice_tds.none?(&:discount?)
        calculate_total_with_tds
      else
        calculate_total
      end
    end

    def calculate_total_without_discounts
      li_total_tax = calculate_li_total
      li_total_tax += li_total_tax * calculate_li_tax_amount_to_add / 100
      total_amount = apply_invoice_tax_on_line_items
      total_amount + (total_amount * calculate_inv_tax_amount_to_add / 100) + li_total_tax
    end

    def calculate_total_with_tds
      total_excluding_tax = invoice_discount
      total_excluding_tax += taxed_line_items_with_invoice_discount * calculate_li_tax_amount_to_add / 100
      total_excluding_tax + untaxed_line_items_with_invoice_discount * calculate_inv_tax_amount_to_add / 100
    end
    
    def calculate_total
   
      total_excluding_tax = taxed_line_items_with_invoice_discount
      total_excluding_tax += taxed_line_items_with_invoice_discount * calculate_li_tax_amount_to_add / 100
      li_invoice_tax = ( (invoice_discount - taxed_line_items_with_invoice_discount) * calculate_inv_tax_amount_to_add / 100)
      li_invoice_tax_total = li_invoice_tax + (invoice_discount - taxed_line_items_with_invoice_discount)
      total_excluding_tax + li_invoice_tax_total
     
     
        # total_excluding_tax = invoice_discount
        # total_excluding_tax += total_excluding_tax * calculate_li_tax_amount_to_add / 100
        # total_excluding_tax + (total_excluding_tax * calculate_inv_tax_amount_to_add / 100)
      
    end

    def taxed_line_items_with_invoice_discount
      line_items.flat_map do |line_item|
        line_item.tax_and_discount_polies.map do |li|
          if li.tax?
            line_item.total + invoice_tds.select(&:discount?).sum(&:amount)
          end
        end
      end.compact.sum
    end
    
    def untaxed_line_items_with_invoice_discount
      li_total = 0
      line_items.each do |line_item|
        if !line_item.tax_and_discount_polies.present? || line_item.tax_and_discount_polies.any? { |li| li.discount? }
          li_total += line_item.total + invoice_tds.select(&:discount?).sum(&:amount)
        end
      end
    
      li_total
    end
    
    def invoice_discount
      amount = sub_total
      invoice_tds.select(&:discount?).map do |discount|
        amount += amount * discount.amount / 100
      end.flatten.sum

      amount.round(2)
    end

    def calculate_li_tax_amount_to_add
      line_items.map do |li|
        li.tax_and_discount_polies.select(&:tax?).sum(&:amount)
      end.uniq.sum
    end

    def calculate_li_total
      li_tax = 0
      line_items.filter_map do |li|
        li_tax += li.total if li.tax_and_discount_polies.any?(&:tax?)
      end.sum
      li_tax
    end

    def calculate_inv_tax_amount_to_add
      if all_line_items_have_own_tax?
        0.0
      elsif !all_line_items_have_own_tax?
        invoice_tds.select(&:tax?).sum(&:amount)
      end
    end

    # implement a method which will imply invoice tax only on line items which
    # don't have their own tax
    def apply_invoice_tax_on_line_items
      return 0.0 if all_line_items_have_own_tax?

      line_items.sum { |li| li.tax_and_discount_polies.any?(&:tax?) ? 0.0 : li.total }
    end

    def line_items_have_own_tax?
      line_items.any? do |line_item|
        line_item.tax_and_discount_polies.any?(&:tax?)
      end
    end

    def line_items_have_own_discount?
      line_items.any? do |line_item|
        line_item.tax_and_discount_polies.any?(&:discount?)
      end
    end

    def all_line_items_have_own_tax?
      line_items.all? do |line_item|
        line_item.tax_and_discount_polies.any?(&:tax?)
      end
    end
  end
end
