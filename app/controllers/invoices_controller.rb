class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: %i[new edit]
  before_action :initiate_invoice, only: %i[new add_line_items]
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
  end

  def add_line_items
    @product = Product.find(params[:product_id])
    @line_item = LineItem.new(
      item_name: @product.name,
      quantity: 1,
      unit_rate: @product.unit_rate,
      product_id: @product.id,
      invoice_id: @invoice.id
    )
   
  end

  # this action is used at three scenarios
  # 1. when user adds/removes a line item
  # 2. when user updates the quantity of line item
  # 3. when user updates the unit rate of line item
  def calculate_sub_total
    line_items = params[:lineItemsAttributes].map do |line_item|
      LineItem.new(
        quantity: line_item[:quantity].to_f,
        unit_rate: line_item[:unitRate].to_f
      )
    end
    @sub_total = ::InvoiceAmountCalculator.new.calculate_sub_total(line_items)

  end

  def delete_line_items
    @line_item = LineItem.find_or_initialize_by(id: params[:line_item_id])
    @line_item.destroy if @line_item.persisted?
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices or /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.user = current_user
    @invoice.sub_total = ::InvoiceAmountCalculator.new.calculate_sub_total(@invoice.line_items)
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
    def initiate_invoice
      @invoice = Invoice.new(user: current_user, status: Invoice::DRAFT)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    def set_category
      @categories = Category.includes(:products).where(user_id: current_user.id)
    end

    # Only allow a list of trusted parameters through.
    def invoice_params
      params.require(:invoice).permit(:line_items_count, :name, :status, :sub_total, :note, :payment_date, :due_date, line_items_attributes: [:id, :item_name, :unit_rate, :quantity, :unit, :product_id])
    end
end
