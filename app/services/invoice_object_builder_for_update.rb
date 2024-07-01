# frozen_string_literal: true

# This class is responsible for building the invoice object
# It will take the invoice params and return the invoice object
# It will also handle the validation of the invoice params
class InvoiceObjectBuilderForUpdate
  def initialize(invoice_id, params)
    @invoice_id = invoice_id
    @invoice_params = params.except(:line_items_attributes)
    @line_items_params = params[:line_items_attributes]
  end

  def call
    return invoice if line_items_params.blank?

    invoice.assign_attributes(invoice_params)
    handle_line_items
    li_mark_for_destruction
    populate_line_item_tds
    invoice
  end

  private

  attr_reader :invoice_params, :line_items_params

  def invoice
    @invoice ||= Invoice.find(@invoice_id)
  end

  # Handles attribute level changes or new line items
  def handle_line_items
    line_items_params.each do |param_id, param|
      db_li = invoice_line_items.find { |line_item| (line_item.id == param_id.to_i) }
      if db_li.present?
        db_li.assign_attributes(param.except(:tax_and_discount_ids))
      else
        invoice_line_items.build(param.except(:tax_and_discount_ids))
      end
    end
  end

  # Handles for deleted line items
  def li_mark_for_destruction
    (invoice_line_items.ids - line_items_params.keys.map(&:to_i)).compact.each do |tbd| # compact is used to avoid nil after the comparision
      li = invoice_line_items.find { |l| tbd == l.id }
      li&.mark_for_destruction
    end
  end

  # Process changes in the tax/discounts of line items
  def populate_line_item_tds
    existing_line_items = invoice_line_items.reject(&:marked_for_destruction?)
    LineItemsTdsProcessor.new(existing_line_items, line_items_params).process
  end

  def td_ids
    ids = line_items_params.to_h.map { |_k, v| v[:tax_and_discount_ids] }.flatten
    @td_ids ||= TaxAndDiscount.where(id: ids).group_by(&:id)
  end

  def invoice_line_items
    @invoice_line_items ||= invoice.line_items
  end
end
