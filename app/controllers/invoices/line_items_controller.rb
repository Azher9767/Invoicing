module Invoices
  class LineItemsController < ApplicationController
    def create
      @product = Product.find(params[:product_id])
      @line_item = LineItem.new(
        item_name: @product.name,
        quantity: 1,
        unit_rate: @product.unit_rate,
        product_id: @product.id,
        invoice_id: @invoice.id
      )
    end
  end

  def destroy
    @line_item = LineItem.find_by(id: params[:line_item_id])
    @line_item.destroy if @line_item.present? && @line_item.persisted? 
  end
end
