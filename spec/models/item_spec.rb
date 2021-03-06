require 'rails_helper'

RSpec.describe Item, type: :model do

  describe 'relationships' do
    it {should belong_to :merchant}
    it {should have_many :invoice_items}
    it {should have_many(:bulk_discounts).through(:merchant)}
    it {should have_many(:invoices).through(:invoice_items)}
    it {should have_many(:transactions).through(:invoices)}
    it {should have_many(:customers).through(:invoices)}
  end

  describe 'validations' do
    it {should validate_presence_of :name}
    it {should validate_presence_of :unit_price}
    it {should validate_numericality_of(:unit_price).is_greater_than_or_equal_to(0)}
  end

  it 'is created with status disabled when not provided' do
    cool = Merchant.create!(name: "Cool Beans")
    red = cool.items.create!(
            name: "Red Paint",
            description: "2 oz of red acrylic paint",
            unit_price: 8.99)

    expect(red.status).to eq("disabled")
    expect(red.disabled?).to eq(true)
    expect(red.enabled?).to eq(false)
  end

  it 'can have status disabled' do
    cool = Merchant.create!(name: "Cool Beans")
    red = cool.items.create!(
            name: "Red Paint",
            description: "2 oz of red acrylic paint",
            unit_price: 8.99)
    red.update!(status: :enabled)

    expect(red.status).to eq("enabled")
    expect(red.disabled?).to eq(false)
    expect(red.enabled?).to eq(true)
  end

  describe 'class methods' do
    describe '::ready_to_ship_by_merchant' do
      it "gets items the have a status that isn't shipped for the merchant" do
        merchant = create(:merchant)
        item1 = create(:item, merchant_id: merchant.id)
        item2 = create(:item, merchant_id: merchant.id)
        invoice1 = create(:invoice)
        create(:invoice_item, item_id: item1.id, invoice_id: invoice1.id, status: :pending)
        create(:invoice_item, item_id: item2.id, invoice_id: invoice1.id, status: :pending)

        expect(Item.ready_to_ship_by_merchant(merchant.id).pluck(:name)).to eq([item1.name, item2.name])
      end
    end
  end
  describe 'instance methods' do
    describe '#top_5_items' do
      it "returns the top 5 items based on total revenue" do
        merchant = Merchant.first
        item1 = Item.find(3)
        item2 = Item.find(13)
        item3 = Item.find(1)
        item4 = Item.find(6)
        item5 = Item.find(5)

        expect(merchant.items.top_5_items.first).to eq(item3)
        expect(merchant.items.top_5_items.second).to eq(item1)
        expect(merchant.items.top_5_items.third).to eq(item5)
        expect(merchant.items.top_5_items.fourth).to eq(item2)
        expect(merchant.items.top_5_items.last).to eq(item4)
        expect(merchant.items.top_5_items.first.total_revenue).to eq(0.2027889e7)
        expect(merchant.items.top_5_items.last.total_revenue).to eq(0.780325e6)
      end
    end
  end
end
