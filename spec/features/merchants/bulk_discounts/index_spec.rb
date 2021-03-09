require 'rails_helper'

RSpec.describe 'As a merchant when I visit my bulk discounts index page' do
  before :each do
    @merchant = Merchant.first
    @merchant2 = Merchant.second
    @merchant3 = Merchant.third
    @bd1 = @merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
    @bd2 = @merchant.bulk_discounts.create!(name: "Discount 2", item_threshold: 15, percent_discount: 15)
    @bd3 = @merchant2.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
    @bd4 = @merchant.bulk_discounts.create!(name: "Discount 3", item_threshold: 20, percent_discount: 20)
  end

  it "I see all of my bulk discounts their percentage discount and quantity thresholds" do
    VCR.use_cassette("CreateNagerPublicHolidays") do
      visit merchant_bulk_discounts_path(@merchant)

      expect(page).to have_content('Bulk Discounts')

      within "#discount-#{@bd1.id}" do
        expect(page).to have_content("#{@bd1.name}")
        expect(page).to have_content("#{@bd1.item_threshold}")
        expect(page).to have_content("#{@bd1.percent_discount/100}%")
      end
    end
  end

  it "if there are no bulk discounts I see a message 'Currently no active bulk discounts'" do
    VCR.use_cassette("CreateNagerPublicHolidays") do
      visit merchant_bulk_discounts_path(@merchant3)

      within ".discounts" do
        expect(page).to have_content("Currently no active discounts")
      end
    end
  end

  it "each bulk discount listed includes a link to its show page" do
    VCR.use_cassette("CreateNagerPublicHolidays") do
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

  it "and I do not see bulk discounts for another merchant" do
    VCR.use_cassette("CreateNagerPublicHolidays") do
      visit merchant_bulk_discounts_path(@merchant)

      expect(page).to_not have_content("#discount-#{@bd3.id}")
    end
  end

  describe "I see a section with a header of 'Upcoming Holidays'" do
    it "In this section the name and date of the next 3 upcoming US holidays are listed" do
      VCR.use_cassette("CreateNagerPublicHolidays") do
        holidays = Holidays.new

        visit merchant_bulk_discounts_path(@merchant)

        within ".upcoming-holidays" do
          expect(page).to have_content("Upcoming Holidays")
          expect(page).to have_content("#{holidays.next_3_public_holidays[0][:name]}")
          expect(page).to have_content("#{holidays.next_3_public_holidays[0][:date]}")
          expect(page).to have_content("#{holidays.next_3_public_holidays[1][:name]}")
          expect(page).to have_content("#{holidays.next_3_public_holidays[1][:date]}")
          expect(page).to have_content("#{holidays.next_3_public_holidays[2][:name]}")
          expect(page).to have_content("#{holidays.next_3_public_holidays[2][:date]}")
        end
      end
    end
  end

  it "I see a button to create a new bulk discount" do
    VCR.use_cassette("CreateNagerPublicHolidays") do
      visit merchant_bulk_discounts_path(@merchant)

      expect(page).to have_button("Create Bulk Discount")
      click_button "Create Bulk Discount"
      expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts/new")
    end
  end

  describe "next to discounts there is a button to delete" do
    it "once clicked I am redirected back to index and I no longer see it" do
      VCR.use_cassette("CreateNagerPublicHolidays") do
        visit merchant_bulk_discounts_path(@merchant)

        within ".discounts" do
          expect(page.all('.button_to', count: 2))

          within "#discount-#{@bd2.id}" do
            expect(page).to have_button("Delete")
            click_button "Delete"
          end

          expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts")
          expect(page).to_not have_content("#{@bd2.name}")
        end
      end
    end

    it "I do not see a delete button next to discounts with pending invoice items" do
      VCR.use_cassette("CreateNagerPublicHolidays") do
        visit merchant_bulk_discounts_path(@merchant)

        within "#discount-#{@bd1.id}" do
          expect(page).to_not have_button("Delete")
          expect(page).to have_content("")
        end
      end
    end
  end
end
