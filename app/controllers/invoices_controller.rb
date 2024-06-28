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
  #   @invoice.line_items.each do |line_item|
  #   if line_item.tax_and_discount_polies.empty?
  #     line_item.tax_and_discount_polies.build
  #   end
  #  end
  end

  # POST /invoices or /invoices.json
  def create
    @invoice = InvoiceObjectBuilderForCreate.new(invoice_params).call
    @invoice.user = current_user
    respond_to do |format|
      if @invoice.save
        format.html { redirect_to invoice_url(@invoice), notice: 'Invoice was successfully created.' }
        format.json { render :show, status: :created, location: @invoice }
      else
        set_category
        format.turbo_stream
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    @exception = e.message

    respond_to(&:turbo_stream)
  end

  # PATCH/PUT /invoices/1 or /invoices/1.json
  def update
    @invoice = InvoiceObjectBuilderForUpdate.new(params[:id], invoice_params).call
    @invoice.user = current_user
    respond_to do |format|
      if @invoice.save
        format.html { redirect_to invoice_url(@invoice), notice: 'Invoice was successfully updated.' }
        format.json { render :show, status: :ok, location: @invoice }
      else
        set_category
        format.turbo_stream { render turbo_stream: turbo_stream.replace('invoice_errors', partial: 'invoices/errors', locals: { errors: @invoice.errors }) }
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
    # params[:invoice][:line_items_attributes].each do |_key, value|
    #   value[:tax_and_discount_polies_attributes] = value[:tax_and_discount_polies_attributes].each do |_k, v|
    #     v[:tax_and_discount_id] = v[:tax_and_discount_id].reject!(&:empty?)
    #   end
    # end if params[:invoice][:line_items_attributes].present?
 
    # params.require(:invoice).permit(
    #   :name, :status, :note, :payment_date, :due_date,
    #   line_items_attributes: [:id, :item_name, :unit_rate, :quantity, :unit, :product_id, tax_and_discount_polies_attributes: [:_destroy, :id, tax_and_discount_id: []]], 
    #   tax_and_discount_polies_attributes: [:id, :name, :td_type, :amount, :tax_and_discount_id]
    #   ).tap do |whitelisted_params|
    #     whitelisted_params[:line_items_attributes]&.each do |_key, value|
    #       if value[:id].present?
    #         value[:tax_and_discount_polies_attributes]&.reject! { |_k, v| v[:id].to_s.empty? }
    #       end
    #     end
    # end
    params.require(:invoice).permit(
      :id, :name, :status, :payment_date, :due_date, :note,
      line_items_attributes: [:id, :item_name, :unit_rate, :quantity, :unit, :product_id, tax_and_discount_ids: []],
      tax_and_discount_polies_attributes: %i[id name td_type amount tax_and_discount_id]
    )
  end
end
