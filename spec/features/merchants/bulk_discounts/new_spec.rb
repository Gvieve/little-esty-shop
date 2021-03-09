require 'rails_helper'

RSpec.describe "As merchant when I click 'Create Bulk discount' I am taken to a new page with a form" do

  before :each do
    @merchant = Merchant.first
    @bd1 = @merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
  end

  it "I fill in the form with valid data I am redirected to bulk discount index and see my new discount" do
    VCR.use_cassette("CreateNewNagerPulbicHolidays") do
      visit new_merchant_bulk_discount_path(@merchant)

      expect(page).to have_content("Create a New Bulk Discount")
      fill_in "bulk_discount[name]", with: "Discount 2"
      fill_in "bulk_discount[item_threshold]", with: 10
      fill_in "bulk_discount[percent_discount]", with: 10
      click_button "Create Bulk discount"

      expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts")
      expect(page).to have_content("Discount 2")
    end
  end

  it "I cannot create a bulk discount without a name" do
    VCR.use_cassette("CreateNewNagerPulbicHolidays") do
      visit new_merchant_bulk_discount_path(@merchant)

      expect(page).to have_content("Create a New Bulk Discount")
      fill_in "bulk_discount[item_threshold]", with: 10
      fill_in "bulk_discount[percent_discount]", with: 10
      click_button "Create Bulk discount"

      expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts")
      expect(page).to have_content("Name can't be blank")
    end
  end

  it "I cannot create a bulk discount without a item threshold" do
    VCR.use_cassette("CreateNewNagerPulbicHolidays") do
      visit new_merchant_bulk_discount_path(@merchant)

      expect(page).to have_content("Create a New Bulk Discount")
      fill_in "bulk_discount[name]", with: "Discount 2"
      fill_in "bulk_discount[percent_discount]", with: 10
      click_button "Create Bulk discount"

      expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts")
      expect(page).to have_content("Item threshold can't be blank")
    end
  end

  it "I cannot create a bulk discount without a percent discount" do
    VCR.use_cassette("CreateNewNagerPulbicHolidays") do
      visit new_merchant_bulk_discount_path(@merchant)

      expect(page).to have_content("Create a New Bulk Discount")
      fill_in "bulk_discount[name]", with: "Discount 2"
      fill_in "bulk_discount[item_threshold]", with: 10
      click_button "Create Bulk discount"

      expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts")
      expect(page).to have_content("Percent discount can't be blank")
    end
  end

  it "I cannot create a bulk discount an percent discount less than 1" do
    VCR.use_cassette("CreateNewNagerPulbicHolidays") do
      visit new_merchant_bulk_discount_path(@merchant)

      expect(page).to have_content("Create a New Bulk Discount")
      fill_in "bulk_discount[name]", with: "Discount 2"
      fill_in "bulk_discount[item_threshold]", with: 10
      fill_in "bulk_discount[percent_discount]", with: 0
      click_button "Create Bulk discount"

      expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts")
      expect(page).to have_content("Percent discount must be greater than or equal to 1")
    end
  end

  it "I cannot create a bulk discount an percent discount greater than 100" do
    VCR.use_cassette("CreateNewNagerPulbicHolidays") do
      visit new_merchant_bulk_discount_path(@merchant)

      expect(page).to have_content("Create a New Bulk Discount")
      fill_in "bulk_discount[name]", with: "Discount 2"
      fill_in "bulk_discount[item_threshold]", with: 10
      fill_in "bulk_discount[percent_discount]", with: 101
      click_button "Create Bulk discount"

      expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts")
      expect(page).to have_content("Percent discount must be less than or equal to 100")
    end
  end
end
