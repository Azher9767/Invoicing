module Invoices
  class TaxAndDiscountPoliesController < ApplicationController
    def create
      @tax_and_discount = TaxAndDiscount.find_by(id: params[:taxAndDiscountId])
      if @tax_and_discount
        @tax_and_discount_poly = TaxAndDiscountPoly.new(
          name: @tax_and_discount.name,
          amount: @tax_and_discount.amount,
          td_type: @tax_and_discount.td_type,
          tax_and_discount_id: @tax_and_discount.id,
          tax_type: @tax_and_discount.tax_type
        )
      else
        name, amount, td_type, tax_type = params[:taxAndDiscountId].split(';')
        @tax_and_discount_poly = TaxAndDiscountPoly.new(
          name: name,
          amount: amount || 0.0,
          td_type: td_type == 'discount' ? 'discount' : 'tax' ,
          tax_and_discount_id: nil,
          tax_type: tax_type == 'percentage' ? 'percentage' : 'fixed',
        )
      end
    end

    def destroy
      @tax_and_discount_poly = TaxAndDiscountPoly.find_by(id: params[:taxAndDiscountId])
      @tax_and_discount_poly.destroy if @tax_and_discount_poly.present? && @tax_and_discount_poly.persisted?
    end
  end
end
