require 'rails_helper'

RSpec.describe 'As an admin, when I visit the admin invoice show page' do
  before :each do
    @invoice = Invoice.all.first
    @invoice_item = @invoice.invoice_items.first
    @customer = @invoice.customer
    @customer.update(address: '123 Main St', city: 'Denver', state: 'CO', zipcode: '80202')
    @customer.save
  end

  it "Then I see an invoice's id, status, and created_at date" do
    visit admin_invoice_path(@invoice)
    expect(current_path).to eq("/admin/invoices/#{@invoice.id}")

    expect(page).to have_content("Invoice ##{@invoice.id}")
    within ".invoice-information" do
      expect(page).to have_content("Created on: #{@invoice.created_at.strftime('%A, %B %d, %Y')}")
    end
  end

  it "And I see the total revenue that will be generated from all of my items on the invoice" do
    visit admin_invoice_path(@invoice)

    within ".invoice-information" do
      expect(page).to have_content("Total Revenue: $1,016,156.00")
      expect(page).to have_content("Total Discounts: $0.00")
      expect(page).to have_content("Grand Total: $1,016,156.00")
    end
  end

  describe "And if there are any discounts applied" do
    it "I see the total revenue, total discounts, and the adjusted grand total" do
      merchant = Merchant.first
      bd1 = merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
      inv_item1 = InvoiceItem.create!(unit_price: 0.100e3, status: "packaged", quantity: 10, item_id: 3, invoice_id: 484)
      invoice484 = Invoice.find(484)

      visit admin_invoice_path(invoice484)

      within ".invoice-information" do
        expect(page).to have_content("Total Revenue: $1,849,077.00")
        expect(page).to have_content("Total Discounts: $100.00")
        expect(page).to have_content("Grand Total: $1,848,977.00")
      end
    end
  end

  it "Then I see the customer full name and address related to that invoice" do
    visit admin_invoice_path(@invoice)

    within ".invoice-customer" do
      expect(page).to have_content("Customer:")
      expect(page).to have_content(@customer.full_name)
      expect(page).to have_content(@customer.address)
      expect(page).to have_content("#{@customer.city}, #{@customer.state} #{@customer.zipcode}")
    end
  end

  describe "Then I see all of my items on the invoice including:" do
    it "item name, quantity ordered, price it sold for, and invoice item status" do

      visit admin_invoice_path(@invoice)

      within ".invoice-items" do
        expect(page).to have_content("Items on this Invoice:")

        within ".invoice-item-#{@invoice_item.id}" do
          expect(page).to have_content(@invoice_item.item.name)
          expect(page).to have_content(@invoice_item.quantity)
          expect(page).to have_content("$78,031.00")
          expect(page).to have_content(@invoice_item.status.titleize)
        end
      end

      describe 'if there are any applicable discounts' do
        it "I see the discount amount which is a link to that discount's show page" do
          visit admin_invoice_path(@invoice)

        end
      end
    end

    it "and the invoice status is a select field with the currrent status selected" do
      visit admin_invoice_path(@invoice)

      expect(page.has_select?('invoice[status]', selected: "#{@invoice.status}"))
    end

    describe "When I click status select field, I can select a new status" do
      it "And I can click 'Update Invoice' and see that the invoice's status is updated" do
        visit admin_invoice_path(@invoice)

        expect(page.has_select?('invoice[status]', selected: "#{@invoice.status}"))
        select 'completed', from: 'invoice[status]'
        click_button("Update Invoice")

        expect(current_path).to eq(admin_invoice_path(@invoice))
        @invoice.reload
        expect(page.has_select?('invoice[status]', selected: "#{@invoice.status}"))
      end
    end
  end
end
