require 'rails_helper'

RSpec.describe 'As a merchant when I visit my bulk discounts index page' do
  before :each do
    @merchant = Merchant.first
    @merchant2 = Merchant.second
    @bd1 = @merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
    @bd2 = @merchant.bulk_discounts.create!(name: "Discount 2", item_threshold: 15, percent_discount: 15)
    @bd3 = @merchant2.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
    @bd4 = @merchant.bulk_discounts.create!(name: "Discount 3", item_threshold: 20, percent_discount: 20)
  end

  it "I see all of my bulk discounts their percentage discount and quantity thresholds" do
    visit merchant_bulk_discounts_path(@merchant)

    expect(page).to have_content('Bulk Discounts')

    within "#discount-#{@bd1.id}" do
      expect(page).to have_content("#{@bd1.name}")
      expect(page).to have_content("#{@bd1.item_threshold}")
      expect(page).to have_content("#{@bd1.percent_discount/100}%")
    end
  end

  it "each bulk discount listed includes a link to its show page" do
    visit merchant_bulk_discounts_path(@merchant)

    within ".discounts" do
      expect(page.all('a', count: 3))

      within "#discount-#{@bd1.id}" do
        expect(page).to have_link("#{@bd1.name}")
        click_link "#{@bd1.name}"
        expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts/#{@bd1.id}")
      end
    end
  end
end
