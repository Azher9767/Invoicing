module Invoices
  class LineItemsController < ApplicationController
    def create
      @product = Product.find_by(id: params[:productId])
      if @product
        @line_item = LineItem.new(
          item_name: @product.name,
          quantity: 1,
          unit_rate: @product.unit_rate,
          product_id: @product.id,
        )
      else
        item_name, quantity, unit_rate = params[:productId].split(';')
        @line_item = LineItem.new(
          item_name: item_name,
          quantity: quantity || 1,
          unit_rate: unit_rate || 0.0,
          product_id: nil
        )
      end
    end

    def destroy
      @line_item = LineItem.find_by(id: params[:id])
      @line_item.destroy if @line_item.present? && @line_item.persisted? 
    end
  end
end
