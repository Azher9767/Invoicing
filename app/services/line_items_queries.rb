# frozen_string_literal: true

module LineItemsQueries # rubocop:disable Style/Documentation
  def line_items_polies
    @line_items_polies ||= line_items.select { |line_item| line_item.tax_and_discount_polies.reject(&:marked_for_destruction?) }
  end
end