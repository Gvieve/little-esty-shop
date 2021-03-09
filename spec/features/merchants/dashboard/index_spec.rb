require 'rails_helper'

RSpec.describe 'Merchant Dashboard' do
  before :each do
    @merchant = Merchant.first
    @customers = @merchant.top_5_customers_by_transactions
  end
  describe "As a merchant," do
    describe "When I visit my merchant dashboard (/merchant/merchant_id/dashboard)" do
      it "Then I see the name of my merchant" do
        visit merchant_dashboard_index_path(@merchant)

        expect(current_path).to eq("/merchant/#{@merchant.id}/dashboard")
        expect(page).to have_content(@merchant.name)
      end

      it "Then I see link to my merchant items index (/merchant/merchant_id/items)" do
        visit merchant_dashboard_index_path(@merchant)

        expect(page).to have_button('My Items')
        click_on ('My Items')
        expect(current_path).to eq("/merchant/#{@merchant.id}/items")
      end

      it "And I see a link to my merchant invoices index (/merchant/merchant_id/invoices)" do
        visit merchant_dashboard_index_path(@merchant)

        expect(page).to have_button('My Invoices')
        click_on ('My Invoices')
        expect(current_path).to eq("/merchant/#{@merchant.id}/invoices")
      end

      it "I see a link to view all my discounts, when clicked I am taken to my bulk discounts index" do
        VCR.use_cassette("CreateNagerPublicHolidays") do
          visit merchant_dashboard_index_path(@merchant)

          expect(page).to have_button('My Discounts')
          click_on 'My Discounts'
          expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts")
        end
      end

      it "I see my top 5 customer names with largest number of successful transactions" do
        visit merchant_dashboard_index_path(@merchant)
        customer1 = Customer.find(108)

        within '.favorite-customers' do
          expect(page).to have_content('Favorite Customers')
          expect(page).to have_content(@customers.first.first_name)
          expect(page).to have_content(@customers.last.first_name)
          expect(@customers.second.last_name).to appear_before(@customers.third.last_name)
          expect(@customers.third.last_name).to appear_before(@customers.fourth.last_name)
          expect(@customers.fourth.last_name).to appear_before(@customers.fifth.last_name)
          expect(page).to_not have_content(customer1.first_name)
        end
      end

      describe "Then I see a section for 'Items Ready to Ship'" do
        it "with a list of item names and that have not been shipped ordered by oldest date created" do
          merchant = create(:merchant)
          item2 = create(:item, merchant_id: merchant.id)
          item1 = create(:item, merchant_id: merchant.id)
          invoice1 = create(:invoice)
          create(:invoice_item, item_id: item1.id, invoice_id: invoice1.id, status: :pending)
          create(:invoice_item, item_id: item2.id, invoice_id: invoice1.id, status: :pending)


          visit merchant_dashboard_index_path(merchant.id)

          expect(page).to have_content("Items Ready to Ship")
          expect(page).to have_content("#{item1.name}")
          expect(page).to have_content("#{invoice1.created_at.strftime('%A, %B %d, %Y')}")
          expect(item2.name).to appear_before(item1.name)
        end

        it "And next to each Item the id of the invoice that is a link to my merchant's invoice show page" do
          item = Item.find(5)
          invoice = Invoice.find(882)
          invoice_item = InvoiceItem.where(item_id: item.id, invoice_id: invoice.id).first

          visit merchant_dashboard_index_path(@merchant)

          within ".item-#{invoice_item.id}" do
            expect(page).to have_link("882")
            expect(page).to_not have_link("121")
            click_link "882"
            expect(current_path).to eq("/merchant/#{@merchant.id}/invoices/882")
          end
        end
      end
    end
  end
end
