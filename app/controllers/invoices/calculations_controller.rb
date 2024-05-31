# this Invoices module class action is used at six scenarios
# 1. when user adds/removes a line item and tax and discount fields
# 2. when user updates the quantity of line item
# 3. when user updates the unit rate of line item
# 4. when user updates the amount of tax and discount
# 5. when user updates the tax type of tax and discount
# 6. when user updates the td type of tax and discount

module Invoices
  class CalculationsController < ApplicationController
    def create
      invoice = Invoice.new
      line_items = calculation_params[:lineItemsAttributes].map do |line_item|
        tax_and_discount_polies_attributes = TaxAndDiscount.where(id: line_item[:tdIds]).map do |td|
          {td_type: td.td_type, amount:  td.amount, name:  td.name}
        end
        if line_item[:quantity].present? && line_item[:unitRate].present?
          LineItem.new(
            quantity: line_item[:quantity].to_f,
            unit_rate: line_item[:unitRate].to_f,
            unit: line_item[:unit],
            tax_and_discount_polies_attributes:
          )
        end
      end
      invoice.line_items = line_items
      
      tax_and_discount_polys = calculation_params[:taxAndDiscountPolyAttributes].map do |td_poly|
        TaxAndDiscountPoly.new(
          amount: td_poly[:amount].to_f,
          td_type: td_poly[:td_type],
          name: td_poly[:name]
        )
      end

      invoice.tax_and_discount_polies = tax_and_discount_polys
      
      @total, @sub_total = InvoiceAmountCalculator.new(invoice.line_items, invoice.tax_and_discount_polys).call
    end

    private

    def calculation_params
      params.require(:calculation).permit(
        lineItemsAttributes: [:quantity, :unitRate, :unit, tdIds: []],
        taxAndDiscountPolyAttributes: [:amount, :td_type, :name]
      )
    end
  end
end
