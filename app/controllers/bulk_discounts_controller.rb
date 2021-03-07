class BulkDiscountsController < ApplicationController
  before_action :find_merchant
  before_action :find_discount, except: [:index]

  def index
    @holidays = Holidays.new
  end

  def show
  end

  private

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end

  def find_discount
    @discount = BulkDiscount.find(params[:id])
  end
end
