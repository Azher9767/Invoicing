class CreateTaxAndDiscountPoly < ActiveRecord::Migration[7.1]
  def change
    create_table :tax_and_discount_polies do |t|
      t.string :name
      t.references :tax_discountable, polymorphic: true, null: false
      t.string :td_type, default: "", null: false
      t.string :tax_type, default: "", null: false
      t.decimal :amount, default: "0.0", null: false
      t.belongs_to :invoice, foreign_key: true
      t.belongs_to :tax_and_discount, foreign_key: true

      t.timestamps
    end
  end
end
