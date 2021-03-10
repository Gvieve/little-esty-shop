class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant
  has_many :invoice_items, through: :items

  validates_presence_of :name, :item_threshold, :percent_discount
  validates_numericality_of :item_threshold
  validates :percent_discount,
    numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100}

  def pending_invoice_items?
    invoice_items
    .where(status: :pending)
    .where("quantity >= ?", item_threshold)
    .any?
  end
end
