class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
  has_many :transactions, through: :invoice
  has_many :bulk_discounts, through: :merchant
  has_one :merchant, through: :item
  has_one :customer, through: :invoice

  validates_presence_of :unit_price, :quantity
  validates :unit_price, :quantity, numericality: { greater_than_or_equal_to: 0 }
  enum status: [:pending, :packaged, :shipped]

  before_save :apply_discount

  def revenue
    unit_price * quantity
  end

  def discount_total
    discount_price ? revenue - (discount_price * quantity) : 0
  end

  def self.top_sales_date
    select('invoices.*, sum(invoice_items.quantity * invoice_items.unit_price) as total_revenues')
    .joins(:transactions)
    .where(transactions: {result: :success})
    .group('invoices.id')
    .order("total_revenues desc", "invoices.created_at desc")
    .first
    .created_at
  end

  def best_discount
    BulkDiscount
    .where(merchant_id: item.merchant_id)
    .where("item_threshold <= ?", quantity)
    .order("item_threshold desc", "bulk_discounts.percent_discount desc")
    .first
  end

  def discount_percentage
    best_discount ? best_discount.percent_discount : nil
  end

  def apply_discount
    if best_discount.nil?
      self.discount_id = nil
      self.discount_price = nil
    else
      self.discount_id = best_discount.id
      self.discount_price = unit_price * ((100 - discount_percentage.to_f)/100)
    end
  end
end
