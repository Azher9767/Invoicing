class AddConstraintsToSubTotalInInvoices < ActiveRecord::Migration[7.1]
  def up
    add_column :invoices, :temp_sub_total, :decimal, null: false, default: 0
    Invoice.reset_column_information
    ActiveRecord::Base.transaction do
      Invoice.all.each do |invoice|
        invoice.update(temp_sub_total: invoice.sub_total)
      end
    end
    
    remove_column :invoices, :sub_total
    rename_column :invoices, :temp_sub_total, :sub_total
  end
end
