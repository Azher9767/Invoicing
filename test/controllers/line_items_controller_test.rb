require "test_helper"

class LineItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @line_item = line_items(:one)
  end

  test "should get index" do
    get line_items_url
    assert_response :success
  end

  test "should get new" do
    get new_line_item_url
    assert_response :success
  end

  test "should create line_item" do
    assert_difference("LineItem.count") do
      post line_items_url, params: { line_item: { item_name: @line_item.item_name, meta: @line_item.meta, product_id: @line_item.product_id, quantity: @line_item.quantity, receipt_id: @line_item.receipt_id, unit: @line_item.unit, unit_rate: @line_item.unit_rate, vendor_amount: @line_item.vendor_amount, vendor_currency: @line_item.vendor_currency } }
    end

    assert_redirected_to line_item_url(LineItem.last)
  end

  test "should show line_item" do
    get line_item_url(@line_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_line_item_url(@line_item)
    assert_response :success
  end

  test "should update line_item" do
    patch line_item_url(@line_item), params: { line_item: { item_name: @line_item.item_name, meta: @line_item.meta, product_id: @line_item.product_id, quantity: @line_item.quantity, receipt_id: @line_item.receipt_id, unit: @line_item.unit, unit_rate: @line_item.unit_rate, vendor_amount: @line_item.vendor_amount, vendor_currency: @line_item.vendor_currency } }
    assert_redirected_to line_item_url(@line_item)
  end

  test "should destroy line_item" do
    assert_difference("LineItem.count", -1) do
      delete line_item_url(@line_item)
    end

    assert_redirected_to line_items_url
  end
end
