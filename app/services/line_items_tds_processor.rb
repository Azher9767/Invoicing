# This class returns a hash after comparing existing tax/discounts for line items
# with new params based on following rules:
# 1. if all taxes/discounts are removed from a line item then new hash will keep that line item so that its polies can be marked for destruction
# 2. if a new tax/discount is being added then new hash will
class LineItemsTdsProcessor
  def initialize(line_items, params)
    @line_items = line_items
    @line_items_params = params
  end

  def process
    line_items_params.each do |line_item_id, line_item_details|
      # check the new changes for the line item
      new_changes = prepare_hash_for_new[line_item_id]
      existing = prepare_hash_for_existing[line_item_id]
      line_item = line_items.find do |li|
        if line_item_details['id'].nil?
          li.id == line_item_details['id']
        else
          li.id.to_s == line_item_details['id']
        end
      end

      if new_changes.nil?
        line_item.tax_and_discount_polies.each(&:mark_for_destruction)
      elsif existing.present? && (existing.keys != new_changes)
        handle_changes(line_item, existing, new_changes)
      else
        populate_polies(line_item, new_changes)
      end
    end
  end

  private

  attr_reader :line_items, :line_items_params

  def prepare_hash_for_new
    line_items_params.to_h.each_with_object({}) do |(line_item_id, line_item_details), new_hash|
      new_hash[line_item_id.to_s] = if line_item_details['tax_and_discount_ids'].present?
                                      line_item_details['tax_and_discount_ids'].map(&:to_s)
                                    else
                                      []
                                    end
    end
  end

  def prepare_hash_for_existing
    line_items.each_with_object({}) do |line_item, new_hash|
      new_hash[line_item.id.to_s] = {}
      line_item.tax_and_discount_polies.each do |poly|
        new_hash[line_item.id.to_s][poly.tax_and_discount_id.to_s] = poly.id.to_s
      end
      new_hash
    end
  end

  def handle_changes(line_item, existing, new_changes) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    if existing.keys.size > new_changes.size # deletion happened
      # find the polies to destroy
      td_ids = existing.keys - new_changes
      destroy_polies(line_item, td_ids)
    elsif existing.keys.size < new_changes.size # addition happened
      td_ids = new_changes - existing.keys
      build_polies(line_item, td_ids)
    elsif existing.keys.size == new_changes.size # update happened
      td_ids = existing.keys - new_changes
      destroy_polies(line_item, td_ids)
      build_polies(line_item, new_changes)
    end
  end

  def destroy_polies(line_item, td_ids)
    line_item.tax_and_discount_polies.select do |poly|
      td_ids.include?(poly.tax_and_discount_id.to_s)
    end.each(&:mark_for_destruction)
  end

  def build_polies(line_item, td_ids)
    fetch_tax_and_discounts(td_ids).each do |td|
      line_item.tax_and_discount_polies.build(name: td.name, td_type: td.td_type, amount: td.amount, tax_and_discount_id: td.id,
                                              tax_discountable: line_item)
    end
  end

  def populate_polies(line_item, td_ids)
    fetch_tax_and_discounts(td_ids).each do |td|
      obj = line_item.tax_and_discount_polies.find { |poly| poly.tax_and_discount_id == td.id }
      line_item.tax_and_discount_polies.build(name: td.name, td_type: td.td_type, amount: td.amount, tax_and_discount_id: td.id) if obj.blank?
    end
  end

  def fetch_tax_and_discounts(td_ids)
    TaxAndDiscount.where(id: td_ids)
  end
end
