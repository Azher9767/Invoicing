module Invoices
  class TaxAndDiscountPoliesController < ApplicationController
    def create
      @tax_and_discount = TaxAndDiscount.find(params[:taxAndDiscountId])
      @tax_and_discount_poly = TaxAndDiscountPoly.new(
        name: @tax_and_discount.name,
        amount: @tax_and_discount.amount,
        td_type: @tax_and_discount.td_type,
        tax_and_discount_id: @tax_and_discount.id,
        tax_type: @tax_and_discount.tax_type
      )
    end

    def destroy
      @tax_and_discount_poly = TaxAndDiscountPoly.find_by(id: params[:taxAndDiscountId])
      @tax_and_discount_poly.destroy if @tax_and_discount_poly.present? && @tax_and_discount_poly.persisted?
    end
  end
end


