require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do

  describe 'relationships' do
    it {should belong_to :item}
    it {should belong_to :invoice}
    it {should have_many(:transactions).through(:invoice)}
    it {should have_many(:bulk_discounts).through(:merchant)}
    it {should have_one(:merchant).through(:item)}
    it {should have_one(:customer).through(:invoice)}
  end

  describe 'validations' do
    it {should validate_presence_of :quantity}
    it {should validate_presence_of :unit_price}
    it {should validate_numericality_of(:unit_price).is_greater_than_or_equal_to(0)}
    it {should validate_numericality_of(:quantity).is_greater_than_or_equal_to(0)}
  end

  it 'status can be pending' do
    @invoice_items = InvoiceItem.all
    expect(@invoice_items.first.status).to eq("pending")
    expect(@invoice_items.first.pending?).to eq(true)
    expect(@invoice_items.first.packaged?).to eq(false)
    expect(@invoice_items.first.shipped?).to eq(false)
  end

  it 'status can be packaged' do
    @invoice_items = InvoiceItem.all
    expect(@invoice_items.second.status).to eq("packaged")
    expect(@invoice_items.second.pending?).to eq(false)
    expect(@invoice_items.second.packaged?).to eq(true)
    expect(@invoice_items.second.shipped?).to eq(false)
  end

  it 'status can be shipped' do
    @invoice_item84 = InvoiceItem.find(84)
     expect(@invoice_item84.status).to eq("shipped")
     expect(@invoice_item84.pending?).to eq(false)
     expect(@invoice_item84.packaged?).to eq(false)
     expect(@invoice_item84.shipped?).to eq(true)
  end

  describe 'instance methods' do
    describe '#revenue' do
      it "calculates revenue of invoice item" do
        invoice_item = create(:invoice_item, unit_price: 2.5, quantity: 3)

        expect(invoice_item.revenue).to eq(7.5)
      end
    end

    describe '#discount_revenue' do
      it "calculates total discount when applicable" do
        merchant = Merchant.first
        bd1 = merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
        inv_item1 = InvoiceItem.create!(unit_price: 0.100e3, status: "packaged", quantity: 10, item_id: 3, invoice_id: 484)
        inv_item2 = merchant.invoice_items.where("quantity <= 10").first

        expect(inv_item1.discount_revenue).to eq(0.1e3)
        expect(inv_item2.discount_revenue).to eq(0)
      end
    end

    describe '#best discount' do
      it "returns the best merchant discount available if applicable based on quantity, or nil if none" do
        merchant = Merchant.first
        bd1 = merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
        bd2 = merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 20)
        inv_item1 = merchant.invoice_items.where("quantity >= 10").first
        inv_item2 = merchant.invoice_items.where("quantity <= 10").first

        expect(inv_item1.best_discount).to eq(bd2)
        expect(inv_item2.best_discount).to be_nil
      end
    end

    describe '#discount_percentage' do
      it "it returns the discount_percent when there is a best discount, or nil" do
        merchant = Merchant.first
        bd1 = merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
        bd2 = merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 20)
        inv_item1 = merchant.invoice_items.where("quantity >= 10").first
        inv_item2 = merchant.invoice_items.where("quantity <= 10").first

        expect(inv_item1.discount_percentage).to eq(20)
        expect(inv_item2.discount_percentage).to be_nil
      end
    end

    describe '#apply_discount' do
      it "when invoice_item is created or updated and has best discount, discount_id and discount_price are saved" do
        merchant = Merchant.first
        bd1 = merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
        bd2 = merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 15, percent_discount: 15)
        inv_item1 = InvoiceItem.create!(unit_price: 0.100e3, status: "packaged", quantity: 10, item_id: 3, invoice_id: 484)

        expect(inv_item1.discount_id).to eq(bd1.id)
        expect(inv_item1.discount_price).to eq(0.9e2)

        inv_item2 = InvoiceItem.find(2654)
        inv_item2.update!(quantity: 15)

        expect(inv_item2.discount_id).to eq(bd2.id)
        expect(inv_item2.discount_price).to eq(0.6384095e5)
      end

      it "when invoice_item has discount and quantity is updated to below item_threshold discount is removed" do
        merchant = Merchant.first
        bd1 = merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
        inv_item1 = InvoiceItem.create!(unit_price: 0.100e3, status: "packaged", quantity: 10, item_id: 3, invoice_id: 484)

        expect(inv_item1.discount_id).to eq(bd1.id)
        expect(inv_item1.discount_price).to eq(0.9e2)

        inv_item1.update!(quantity: 8)
        expect(inv_item1.discount_id).to be_nil
        expect(inv_item1.discount_price).to be_nil
      end
    end
  end

  describe 'class methods' do
    describe '::top_sales_date' do
      it "returns the date with most sales based on total_revenue" do
        @invoice = Invoice.find(323)
        expect(InvoiceItem.top_sales_date).to eq(@invoice.created_at)
      end
    end
  end
end
