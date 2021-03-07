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
