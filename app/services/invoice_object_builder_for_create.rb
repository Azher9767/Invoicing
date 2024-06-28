# This class is responsible for building the invoice object
# It will take the invoice params and return the invoice object
# It will also handle the validation of the invoice params

class InvoiceObjectBuilderForCreate
  def initialize(params)
    @invoice_params = params.except(:line_items_attributes)
    @line_items_params = params[:line_items_attributes]
  end

  def call
    return invoice if line_items_params.blank?

    line_items_tds = TaxAndDiscount.where(id: line_items_td_ids).group_by(&:id)

    line_items_params.each do |_id, li|
      line_item = invoice.line_items.build(li.except(:tax_and_discount_ids))
      next unless li[:tax_and_discount_ids].present?

      li[:tax_and_discount_ids].each do |id|
        td_object = line_items_tds[id.to_i]

        next unless td_object.present?

        line_item.tax_and_discount_polies.build(
          name: td_object[0][:name],
          td_type: td_object[0][:td_type],
          amount: td_object[0][:amount],
          tax_and_discount_id: td_object[0][:id]
        )
      end
    end
    invoice
  end

  private

  attr_reader :invoice_params, :line_items_params

  def invoice
    @invoice ||= Invoice.new(invoice_params)
  end

  def line_items_td_ids
    line_items_params.to_h.map { |_k, v| v[:tax_and_discount_ids] }.flatten
  end
end
