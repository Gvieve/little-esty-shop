require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
  describe 'relationships' do
    it {should belong_to :merchant}
    it {should have_many(:items).through(:merchant)}
    it {should have_many(:invoice_items).through(:items)}
  end

  describe 'validations' do
    it {should validate_presence_of :name}
    it {should validate_presence_of :item_threshold}
    it {should validate_presence_of :percent_discount}
    it {should validate_numericality_of :item_threshold}
    it {should validate_numericality_of(:percent_discount).is_greater_than_or_equal_to(1)}
    it {should validate_numericality_of(:percent_discount).is_less_than_or_equal_to(100)}
  end

  describe 'instance methods' do
    describe 'pending_invoice_items?' do
      it "returns true if there are pending invoice items for a bulk discount" do
        merchant = Merchant.first
        bd1 = merchant.bulk_discounts.create!(name: "Discount 1", item_threshold: 10, percent_discount: 10)
        bd2 = merchant.bulk_discounts.create!(name: "Discount 2", item_threshold: 15, percent_discount: 15)

        expect(bd1.pending_invoice_items?).to eq(true)
        expect(bd2.pending_invoice_items?).to eq(false)
      end
    end
  end
end
