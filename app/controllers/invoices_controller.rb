class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: %i[new edit]
  before_action :set_invoice, only: %i[ show edit update destroy ]

  # GET /invoices or /invoices.json
  def index
    @invoices = Invoice.all
  end

  # GET /invoices/1 or /invoices/1.json
  def show
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new(user: current_user, status: Invoice::DRAFT)
  end

  def add_td_fields
    @tax_and_discount = TaxAndDiscount.find(params[:taxAndDiscountId])
    @tax_and_discount_poly = TaxAndDiscountPoly.new(
      name: @tax_and_discount.name,
      amount: @tax_and_discount.amount,
      td_type: @tax_and_discount.td_type,
      tax_and_discount_id: @tax_and_discount.id,
      tax_type: @tax_and_discount.tax_type
    )
  end

  # this action is used at three scenarios
  # 1. when user adds/removes a line item
  # 2. when user updates the quantity of line item
  # 3. when user updates the unit rate of line item
  def calculate_sub_total
    line_items = params[:lineItemsAttributes].map do |line_item|
      if line_item[:quantity].present? && line_item[:unitRate].present?
        LineItem.new(
          quantity: line_item[:quantity].to_f,
          unit_rate: line_item[:unitRate].to_f
        )
      end
    end

    tax_and_discount_polys = params[:taxAndDiscountPolyAttributes].map do |td_poly|
      TaxAndDiscountPoly.new(
        amount: td_poly[:amount].to_f,
        td_type: td_poly[:td_type],
        name: td_poly[:name],
        tax_type: td_poly[:tax_type]
      )
    end
    
    @sub_total = ::InvoiceAmountCalculator.new.calculate_sub_total(line_items, tax_and_discount_polys)
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices or /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.user = current_user
    @invoice.sub_total = ::InvoiceAmountCalculator.new.calculate_sub_total(@invoice.line_items, @invoice.tax_and_discount_polies)
    respond_to do |format|
      if @invoice.save
        format.html { redirect_to invoice_url(@invoice), notice: "Invoice was successfully created." }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoices/1 or /invoices/1.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_to invoice_url(@invoice), notice: "Invoice was successfully updated." }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1 or /invoices/1.json
  def destroy
    @invoice.destroy!
    respond_to do |format|
      format.html { redirect_to invoices_url, notice: "Invoice was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    def set_category
      @categories = Category.includes(:products).where(user_id: current_user.id)
    end

    # Only allow a list of trusted parameters through.
    def invoice_params
      params.require(:invoice).permit(:line_items_count, :name, :status, :sub_total, :note, :payment_date, :due_date,
      line_items_attributes: [:id, :item_name, :unit_rate, :quantity, :unit, :product_id],
      tax_and_discount_polies_attributes: [:id, :name, :td_type, :amount, :tax_type])
    end
end
