class ChangeBulkDiscountsPercentDiscount < ActiveRecord::Migration[5.2]
  def change
    change_column :bulk_discounts, :percent_discount, :integer
  end
end
