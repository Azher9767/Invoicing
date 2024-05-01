class AddTotalToInvoices < ActiveRecord::Migration[7.1]
  def change
    add_column :invoices, :total, :decimal, null: false, default: 0.0
  end
end
