class TaxAndDiscountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tax_and_discount, only: %i[ show edit update destroy ]

  # GET /tax_and_discounts or /tax_and_discounts.json
  def index
    @tax_and_discounts = TaxAndDiscount.all
  end

  # GET /tax_and_discounts/1 or /tax_and_discounts/1.json
  def show
  end

  # GET /tax_and_discounts/new
  def new
    @tax_and_discount = TaxAndDiscount.new
  end

  # GET /tax_and_discounts/1/edit
  def edit
  end

  # POST /tax_and_discounts or /tax_and_discounts.json
  def create
    @tax_and_discount = TaxAndDiscount.new(tax_and_discount_params)
    @tax_and_discount.user_id = current_user.id
  
    respond_to do |format|
      if @tax_and_discount.save
        format.html { redirect_to tax_and_discount_url(@tax_and_discount), notice: "Tax and discount was successfully created." }
        format.json { render :show, status: :created, location: @tax_and_discount }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tax_and_discount.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tax_and_discounts/1 or /tax_and_discounts/1.json
  def update
    respond_to do |format|
      if @tax_and_discount.update(tax_and_discount_params)
        format.html { redirect_to tax_and_discount_url(@tax_and_discount), notice: "Tax and discount was successfully updated." }
        format.json { render :show, status: :ok, location: @tax_and_discount }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tax_and_discount.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tax_and_discounts/1 or /tax_and_discounts/1.json
  def destroy
    @tax_and_discount.destroy!

    respond_to do |format|
      format.html { redirect_to tax_and_discounts_url, notice: "Tax and discount was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tax_and_discount
      @tax_and_discount = TaxAndDiscount.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def tax_and_discount_params
      params.require(:tax_and_discount).permit(:name, :description, :td_type, :amount)
    end
end
