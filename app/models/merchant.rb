class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :bulk_discounts, dependent: :destroy
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices
  has_many :customers, through: :invoices

  validates_presence_of :name

  enum status: [:disabled, :enabled]

  def self.top_5_by_revenue
    select('merchants.*, sum(invoice_items.quantity * invoice_items.unit_price) as total_revenue')
    .joins(:transactions)
    .where(transactions: {result: :success})
    .group(:id)
    .order('total_revenue desc')
    .limit(5)
  end

  def distinct_invoices
    invoices.distinct
  end

  def top_5_items
    items.top_5_items
  end

  def top_5_customers_by_transactions
     invoices
     .joins(:customer, :transactions)
     .select("customers.*, count(transactions.id) as transaction_count")
     .group("customers.id")
     .where(transactions: {result: :success})
     .order("transaction_count desc, customers.last_name")
     .limit(5)
  end
end
