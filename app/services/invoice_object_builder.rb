# frozen_string_literal: true

# This class is responsible for building the invoice object
# It will take the invoice params and return the invoice object
# It will also handle the validation of the invoice params
class InvoiceObjectBuilder
  def initialize(params)
    @invoice_params = params.except(:line_items_attributes)
    @line_items_params = params[:line_items_attributes]
  end

  def call
    return invoice if line_items_params.blank?

    handle_line_items
    populate_line_item_tds
    invoice
  end

  private

  attr_reader :invoice_params, :line_items_params

  def invoice
    @invoice ||= if invoice_params[:id].present?
                   inv = Invoice.find(invoice_params[:id])
                   inv.assign_attributes(invoice_params)
                   inv
                 else
                   Invoice.new(invoice_params)
                 end
  end

  def handle_line_items # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    # Handles attribute level changes or new line items
    line_items_params.each do |param_id, param|
      db_li = invoice_line_items.find { |line_item| (line_item.id == param_id) }
      if db_li.present?
        db_li.assign_attributes(param.except(:tax_and_discount_ids))
      else
        invoice_line_items.build(param)
      end
    end

    # handles for deleted line items
    (invoice_line_items.ids - line_items_params.keys).each do |tbd|
      li = invoice_line_items.find { |l| tbd == l.id }
      li&.mark_for_destruction
    end
  end

  def populate_line_item_tds
    invoice_line_items.each do |li|
      objects = TaxAndDiscount.where(id: li.tax_and_discount_ids)
      li.tax_and_discount_polies.each do |litd|
        td = objects.find { |obj| obj.id == litd.tax_and_discount_id }
        litd.assign_attributes(td.attributes_for_polies)
      end
    end

    hash_of_db_li_and_td_ids = {}
    invoice_line_items.each do |invoice_line_item|
      line_item_id = invoice_line_item.id
      tax_d_ids = invoice_line_item.tax_and_discount_ids
      td_poly = invoice_line_item.tax_and_discount_polies.ids
      hash_of_db_li_and_td_ids[line_item_id] = { tax_d_ids => td_poly }
    end

    hash_of_tax_params_li_and_td_ids = line_items_params.each_with_object({}) do |(line_item_id, params), new_hash|
      new_hash[line_item_id] = params['tax_and_discount_ids']
    end

    final_hash = {}
    hash_of_db_li_and_td_ids.each do |line_item_id, db_tax_and_discount_ids_hash|
      next if hash_of_tax_params_li_and_td_ids[line_item_id].nil?

      db_td_poly = db_tax_and_discount_ids_hash.values - hash_of_tax_params_li_and_td_ids[line_item_id]
      final_hash = { line_item_id => { db_tax_and_discount_ids_hash.map { |k, _v| k }.first => db_td_poly } }
    end

    td_polies = invoice_line_items.map do |line_item|
      line_item.tax_and_discount_polies if line_item.id == final_hash.keys.first
    end

    td_polies.flatten.compact.each(&:mark_for_destruction)
  end

  def td_ids
    ids = line_items_params.to_h.map { |_k, v| v[:tax_and_discount_ids] }.flatten
    @td_ids ||= TaxAndDiscount.where(id: ids).group_by(&:id)
  end

  def invoice_line_items
    @invoice_line_items ||= invoice.line_items
  end
end
