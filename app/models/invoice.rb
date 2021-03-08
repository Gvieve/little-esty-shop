class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :transactions, dependent: :destroy
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  enum status: [:in_progress, :cancelled, :completed]

  scope :incomplete_invoices, -> { includes(:invoice_items).where.not(status: 2).distinct.order(:created_at)}

  def total_revenue
    invoice_items.sum(&:revenue)
  end

  def total_discount_revenue
    invoice_items.sum(&:discount_revenue)
  end
end
