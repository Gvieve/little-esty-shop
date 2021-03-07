require 'rails_helper'

RSpec.describe 'As a merchant when I visit my bulk discount show page' do
  before :each do
    @merchant = Merchant.first
    @bd1 = @merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
  end

  it "Then I see the bulk discount's name, quantity threshold, and percentage discount" do
    visit merchant_bulk_discount_path(@merchant, @bd1)

    expect(page).to have_content("#{@bd1.name}")
    expect(page).to have_content("Item Threshold: #{@bd1.item_threshold}")
    expect(page).to have_content("Discount Percent: #{@bd1.percent_discount}")
  end

end
