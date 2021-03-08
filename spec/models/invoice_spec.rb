require 'rails_helper'
require 'date'
RSpec.describe Invoice, type: :model do

  describe 'relationships' do
    it {should belong_to :customer}
    it {should have_many :invoice_items}
    it {should have_many :transactions}
    it {should have_many(:items).through(:invoice_items)}
    it {should have_many(:merchants).through(:items)}
  end

  it 'status can be in_progress' do
    invoice12 = Invoice.find(12)
    expect(invoice12.status).to eq("in_progress")
    expect(invoice12.cancelled?).to eq(false)
    expect(invoice12.completed?).to eq(false)
    expect(invoice12.in_progress?).to eq(true)
  end

  it 'status can be cancelled' do
    invoice29 = Invoice.find(29)
    expect(invoice29.status).to eq("cancelled")
    expect(invoice29.cancelled?).to eq(true)
    expect(invoice29.completed?).to eq(false)
    expect(invoice29.in_progress?).to eq(false)
  end

  it 'status can be completed' do
    invoice17 = Invoice.find(17)
    expect(invoice17.status).to eq("completed")
    expect(invoice17.cancelled?).to eq(false)
    expect(invoice17.completed?).to eq(true)
    expect(invoice17.in_progress?).to eq(false)
  end

  describe 'instance methods' do
    describe '#total_revenue' do
      it "gets sum of revenue for all invoice items on the invoice" do
        invoice17 = Invoice.find(17)

        expect(invoice17.total_revenue).to eq(0.2474251e7)
      end
    end

    describe '#total_discount_revenue' do
      it "returns sum of any discounts applicable, or 0" do
        merchant = Merchant.first
        bd1 = merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
        inv_item1 = InvoiceItem.create!(unit_price: 0.100e3, status: "packaged", quantity: 10, item_id: 3, invoice_id: 484)
        invoice484 = Invoice.find(484)
        invoice17 = Invoice.find(17)

        expect(invoice484.total_discount_revenue).to eq(0.1e3)
        expect(invoice17.total_discount_revenue).to eq(0)
      end
    end

    describe '#grand_total_revenue' do
      it "returns total_revenue less total_discount_revenue" do
        merchant = Merchant.first
        bd1 = merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
        inv_item1 = InvoiceItem.create!(unit_price: 0.100e3, status: "packaged", quantity: 10, item_id: 3, invoice_id: 484)
        invoice484 = Invoice.find(484)
        invoice17 = Invoice.find(17)

        expect(invoice484.grand_total_revenue).to eq(0.1848977e7)
        expect(invoice17.grand_total_revenue).to eq(0.2474251e7)
      end
    end
  end
end
