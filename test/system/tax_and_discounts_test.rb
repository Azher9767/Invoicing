require "application_system_test_case"

class TaxAndDiscountsTest < ApplicationSystemTestCase
  setup do
    @tax_and_discount = tax_and_discounts(:one)
  end

  test "visiting the index" do
    visit tax_and_discounts_url
    assert_selector "h1", text: "Tax and discounts"
  end

  test "should create tax and discount" do
    visit tax_and_discounts_url
    click_on "New tax and discount"

    fill_in "Amount", with: @tax_and_discount.amount
    fill_in "Belongs to", with: @tax_and_discount.belongs_to
    fill_in "Description", with: @tax_and_discount.description
    fill_in "Name", with: @tax_and_discount.name
    fill_in "Td type", with: @tax_and_discount.td_type
    fill_in "User", with: @tax_and_discount.user
    click_on "Create Tax and discount"

    assert_text "Tax and discount was successfully created"
    click_on "Back"
  end

  test "should update Tax and discount" do
    visit tax_and_discount_url(@tax_and_discount)
    click_on "Edit this tax and discount", match: :first

    fill_in "Amount", with: @tax_and_discount.amount
    fill_in "Belongs to", with: @tax_and_discount.belongs_to
    fill_in "Description", with: @tax_and_discount.description
    fill_in "Name", with: @tax_and_discount.name
    fill_in "Td type", with: @tax_and_discount.td_type
    fill_in "User", with: @tax_and_discount.user
    click_on "Update Tax and discount"

    assert_text "Tax and discount was successfully updated"
    click_on "Back"
  end

  test "should destroy Tax and discount" do
    visit tax_and_discount_url(@tax_and_discount)
    click_on "Destroy this tax and discount", match: :first

    assert_text "Tax and discount was successfully destroyed"
  end
end
