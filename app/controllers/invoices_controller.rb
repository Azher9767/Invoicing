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

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices or /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.user = current_user
    respond_to do |format|
      if @invoice.save
        format.html { redirect_to invoice_url(@invoice), notice: "Invoice was successfully created." }
        format.json { render :show, status: :created, location: @invoice }
      else
        @categories = Category.includes(:products).where(user_id: current_user.id)
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
        @categories = Category.includes(:products).where(user_id: current_user.id)
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
      params.require(:invoice).permit(:line_items_count, :name, :status, :note, :payment_date, :due_date,
      line_items_attributes: [:id, :item_name, :unit_rate, :quantity, :unit, :product_id],
      tax_and_discount_polies_attributes: [:id, :name, :td_type, :amount])
    end
end
