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

    line_items_tds = TaxAndDiscount.where(id: line_items_td_ids).group_by(&:id)
  
    line_items_params.each do |_id, li|
      line_item = invoice.line_items.build(li.except(:tax_and_discount_polies_attributes))
      li[:tax_and_discount_polies_attributes]&.each do |_id, td|
        td[:tax_and_discount_id].each do |id|
          td_object = line_items_tds[id.to_i]
        
          if td_object.present?
            line_item.tax_and_discount_polies.build(
              name: td_object[0][:name],
              td_type: td_object[0][:td_type],
              amount: td_object[0][:amount],
              tax_and_discount_id: td_object[0][:id]
            )
          end
        end
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
    ids = []
    line_items_params.each do |_id, li|
      next unless li[:tax_and_discount_polies_attributes]

      li[:tax_and_discount_polies_attributes].each do |_id, td|
        ids << td[:tax_and_discount_id]
      end
    end
    ids.flatten.map { |arr| arr }
  end
end
