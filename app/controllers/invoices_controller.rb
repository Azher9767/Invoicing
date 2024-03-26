class InvoicesController < ApplicationController
  before_action :authenticate_user!
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
    @categories = Category.includes(:products).where(user_id: current_user.id)
    #here  we are creating new associating object of line_item
    @invoice.line_items.build 
  end

  def add_line_items
    @product = Product.find(params[:product_id])
    @line_item_fields = LineItem.new(item_name: @product.name, quantity: @product.unit, unit_rate: @product.unit_rate, product_id: @product.id)
    puts "*"*10
    puts @invoice.inspect
    @invoice.line_items << @line_item_fields
    puts @invoice.line_items.length
    
    respond_to do |format|
      format.turbo_stream 
    end
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
      @invoice ||= Invoice.new(user_id: current_user.id)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def invoice_params
      params.require(:invoice).permit(:line_items_count, :name, :status, :sub_total, :note, :payment_date, :due_date, line_items_attributes: [:id, :item_name, :unit_rate, :quantity, :unit, :product_id])
    end
end
