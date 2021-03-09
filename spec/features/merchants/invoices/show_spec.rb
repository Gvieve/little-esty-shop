require 'rails_helper'

RSpec.describe "As a merchant, when I visit my merchant's invoice show page(/merchant/merchant_id/invoices/invoice_id)" do
  before :each do
    @merchant = Merchant.first
    @invoice = @merchant.invoices.first
    @invoice_item = @invoice.invoice_items.first
    @customer = @invoice.customer
    @customer.update(address: '123 Main St', city: 'Denver', state: 'CO', zipcode: '80202')
    @customer.save
  end

  it "Then I see the invoice id, status, and created_at date" do
    visit merchant_invoice_path(@merchant, @invoice)
    expect(current_path).to eq("/merchant/#{@merchant.id}/invoices/#{@invoice.id}")

    expect(page).to have_content("Invoice ##{@invoice.id}")
    within ".invoice-information" do
      expect(page).to have_content("Status: #{@invoice.status.titleize}")
      expect(page).to have_content("Created on: #{@invoice.created_at.strftime('%A, %B %d, %Y')}")
    end
  end

  it "And I see the total revenue that will be generated from all of my items on the invoice" do
    visit merchant_invoice_path(@merchant, @invoice)

    within ".invoice-information" do
      expect(page).to have_content("Total Revenue: $1,281,794.00")
      expect(page).to have_content("Total Discounts: $0.00")
      expect(page).to have_content("Grand Total: $1,281,794.00")
    end
  end

  it "Then I see all of the customer information related to that merchant" do
    visit merchant_invoice_path(@merchant, @invoice)

    within ".invoice-customer" do
      expect(page).to have_content("Customer:")
      expect(page).to have_content(@customer.full_name)
      expect(page).to have_content(@customer.address)
      expect(page).to have_content("#{@customer.city}, #{@customer.state} #{@customer.zipcode}")
    end
  end

  describe "And if there are any discounts applied" do
    it "I see the total revenue, total discounts, and the adjusted grand total" do
      bd1 = @merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
      inv_item1 = InvoiceItem.create!(unit_price: 0.100e3, status: "packaged", quantity: 10, item_id: 3, invoice_id: 484)
      invoice484 = Invoice.find(484)

      visit merchant_invoice_path(@merchant, invoice484)

      within ".invoice-information" do
        expect(page).to have_content("Total Revenue: $1,849,077.00")
        expect(page).to have_content("Total Discounts: $100.00")
        expect(page).to have_content("Grand Total: $1,848,977.00")
      end
    end
  end

  describe "Then I see all of my items on the invoice including:" do
    it "item name, quantity ordered, price it sold for, and invoice item status" do
      visit merchant_invoice_path(@merchant, @invoice)

      within ".invoice-items" do
        expect(page).to have_content("Items on this Invoice:")

        within ".invoice-item-#{@invoice_item.id}" do
          expect(page).to have_content(@invoice_item.item.name)
          expect(page).to have_content(@invoice_item.quantity)
          expect(page).to have_content("$22,582.00")
        end
      end
    end
  end

  describe 'if there are any applicable discounts' do
    it "I see the discount amount and percent on each item" do
      bd1 = @merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
      invoice484 = Invoice.find(484)
      invoice_item = InvoiceItem.where("invoice_id = 484", "quantity >= 10").first
      invoice_item.update!(status: :pending)

      visit merchant_invoice_path(@merchant, invoice484)

      within ".invoice-item-#{invoice_item.id}" do
        expect(page).to have_content(invoice_item.item.name)
        expect(page).to have_content("$32,301.00")
        expect(page).to have_content("$29,070.90")
        expect(page).to have_content("10%")
      end
    end
  end

  it "and each discount amount is a link to that discount's show page" do
    # merchant = Merchant.first
    bd1 = @merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
    invoice484 = Invoice.find(484)
    invoice_item = InvoiceItem.where("invoice_id = 484", "quantity >= 10").first
    invoice_item.update!(status: :pending)
    invoice_item.reload

    visit merchant_invoice_path(@merchant, invoice484)
    # main = page.driver.browser

    within ".invoice-item-#{invoice_item.id}" do
      expect(page).to have_link("#{invoice_item.discount_percent}")
      click_link "#{invoice_item.discount_percent}"

      # popup = page.driver.browser.find_window('popup')
      # page.driver.browser.switch_to.window(popup)
      # expect(current_path).to eq(merchant_bulk_discount_path(merchant, invoice_item.discount_id))
      # expect(page).to have_content("#{bd1.name}")
    end
  end

  describe "When I click status select field, I can select a new Status" do
    it "And I can click 'Update Item Status' abd see that the item's status is updated" do
      visit merchant_invoice_path(@merchant, @invoice)


      within ".invoice-item-#{@invoice_item.id}" do
        select 'shipped', from: 'invoice_item[status]'
        expect(page).to have_button("Update Item Status")

        click_button("Update Item Status")
        expect(current_path).to eq("/merchant/#{@merchant.id}/invoices/#{@invoice.id}")
        expect(page.has_select?('invoice_item[status]', selected: 'shipped'))
      end
    end
  end
end
