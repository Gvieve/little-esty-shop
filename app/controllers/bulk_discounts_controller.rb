class BulkDiscountsController < ApplicationController
  before_action :find_merchant
  before_action :find_discount, except: [:index, :new, :create]

  def index
    @holidays = Holidays.new
  end

  def show
  end

  def new
    @discount = BulkDiscount.new
  end

  def create
    @discount = @merchant.bulk_discounts.new(discount_params)

    if @discount.save
      redirect_to merchant_bulk_discounts_path(@merchant)
    else
      flash[:errors] = @discount.errors.full_messages
      render :new
    end
  end

  private

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end

  def find_discount
    @discount = BulkDiscount.find(params[:id])
  end

  def discount_params
    params.permit(:name, :item_threshold, :percent_discount)
  end
end
