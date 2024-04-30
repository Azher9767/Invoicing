class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :line_items_count
      t.string :name
      t.string :status
      t.decimal :total
      t.decimal :sub_total
      t.text :note
      t.datetime :payment_date
      t.date :due_date

      t.timestamps
    end
  end
end
