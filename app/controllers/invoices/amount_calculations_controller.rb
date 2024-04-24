# this Invoices module class action is used at six scenarios
# 1. when user adds/removes a line item and tax and discount fields
# 2. when user updates the quantity of line item
# 3. when user updates the unit rate of line item
# 4. when user updates the amount of tax and discount
# 5. when user updates the tax type of tax and discount
# 6. when user updates the td type of tax and discount

module Invoices
  class AmountCalculationsController < ApplicationController
    def calculate_sub_total
      line_items = params[:lineItemsAttributes].map do |line_item|
        if line_item[:quantity].present? && line_item[:unitRate].present?
          LineItem.new(
            quantity: line_item[:quantity].to_f,
            unit_rate: line_item[:unitRate].to_f
          )
        end
      end

      tax_and_discount_polys = params[:taxAndDiscountPolyAttributes].map do |td_poly|
        TaxAndDiscountPoly.new(
          amount: td_poly[:amount].to_f,
          td_type: td_poly[:td_type],
          name: td_poly[:name],
          tax_type: td_poly[:tax_type]
        )
      end
      
      @sub_total = ::InvoiceAmountCalculator.new.calculate_sub_total(line_items, tax_and_discount_polys)
    end
  end
end
