require 'rails_helper'

RSpec.describe 'As a merchant when I visit my bulk discount edit page' do
  before :each do
    @merchant = Merchant.first
    @bd1 = @merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 5)
  end

  it "I see form to edit the discount that's pre-populated with the name, quantity threshold, and percentage discount" do
    visit edit_merchant_bulk_discount_path(@merchant, @bd1)

    expect(page).to have_field("name", with: "#{@bd1.name}")
    expect(page).to have_field("item_threshold", with: "#{@bd1.item_threshold}")
    expect(page).to have_field("percent_discount", with: "#{@bd1.percent_discount}")
  end

  it "if I enter valid data in the form and select Update I am redirected back to that discounts show page" do
    visit edit_merchant_bulk_discount_path(@merchant, @bd1)

    fill_in "name", with: "10% off 12"
    fill_in "item_threshold", with: 12
    fill_in "percent_discount", with: 10
    click_button "Update Bulk Discount"

    expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts/#{@bd1.id}")
    @bd1.reload
    expect(page).to have_content("#{@bd1.name}")
    expect(page).to have_content("Item Threshold: #{@bd1.item_threshold}")
    expect(page).to have_content("Discount Percent: #{@bd1.percent_discount}")
  end

  it "I cannot update a discount without a name" do
    visit edit_merchant_bulk_discount_path(@merchant, @bd1)

    fill_in "name", with: ""
    fill_in "item_threshold", with: 12
    fill_in "percent_discount", with: 10
    click_button "Update Bulk Discount"

    expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts/#{@bd1.id}")
    expect(page).to have_content("Name can't be blank")
  end

  it "I cannot update a discount without an item threshold" do
    visit edit_merchant_bulk_discount_path(@merchant, @bd1)

    fill_in "name", with: "10% off 12"
    fill_in "item_threshold", with: ""
    fill_in "percent_discount", with: 10
    click_button "Update Bulk Discount"

    expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts/#{@bd1.id}")
    expect(page).to have_content("Item threshold can't be blank")
  end

  it "I cannot update a discount without a discount percent" do
    visit edit_merchant_bulk_discount_path(@merchant, @bd1)

    fill_in "name", with: "10% off 12"
    fill_in "item_threshold", with: 12
    fill_in "percent_discount", with: ""
    click_button "Update Bulk Discount"

    expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts/#{@bd1.id}")
    expect(page).to have_content("Percent discount can't be blank")
  end

  it "I cannot update a discount with a discount percent less than 1" do
    visit edit_merchant_bulk_discount_path(@merchant, @bd1)

    fill_in "name", with: "10% off 12"
    fill_in "item_threshold", with: 12
    fill_in "percent_discount", with: 0
    click_button "Update Bulk Discount"

    expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts/#{@bd1.id}")
    expect(page).to have_content("Percent discount must be greater than or equal to 1")
  end

  it "I cannot update a discount with a discount percent greater than 100" do
    visit edit_merchant_bulk_discount_path(@merchant, @bd1)

    fill_in "name", with: "10% off 12"
    fill_in "item_threshold", with: 12
    fill_in "percent_discount", with: 101
    click_button "Update Bulk Discount"

    expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts/#{@bd1.id}")
    expect(page).to have_content("Percent discount must be less than or equal to 100")
  end
end
