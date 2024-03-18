require "test_helper"

class TaxAndDiscountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tax_and_discount = tax_and_discounts(:one)
  end

  test "should get index" do
    get tax_and_discounts_url
    assert_response :success
  end

  test "should get new" do
    get new_tax_and_discount_url
    assert_response :success
  end

  test "should create tax_and_discount" do
    assert_difference("TaxAndDiscount.count") do
      post tax_and_discounts_url, params: { tax_and_discount: { amount: @tax_and_discount.amount, belongs_to: @tax_and_discount.belongs_to, description: @tax_and_discount.description, name: @tax_and_discount.name, td_type: @tax_and_discount.td_type, user: @tax_and_discount.user } }
    end

    assert_redirected_to tax_and_discount_url(TaxAndDiscount.last)
  end

  test "should show tax_and_discount" do
    get tax_and_discount_url(@tax_and_discount)
    assert_response :success
  end

  test "should get edit" do
    get edit_tax_and_discount_url(@tax_and_discount)
    assert_response :success
  end

  test "should update tax_and_discount" do
    patch tax_and_discount_url(@tax_and_discount), params: { tax_and_discount: { amount: @tax_and_discount.amount, belongs_to: @tax_and_discount.belongs_to, description: @tax_and_discount.description, name: @tax_and_discount.name, td_type: @tax_and_discount.td_type, user: @tax_and_discount.user } }
    assert_redirected_to tax_and_discount_url(@tax_and_discount)
  end

  test "should destroy tax_and_discount" do
    assert_difference("TaxAndDiscount.count", -1) do
      delete tax_and_discount_url(@tax_and_discount)
    end

    assert_redirected_to tax_and_discounts_url
  end
end
