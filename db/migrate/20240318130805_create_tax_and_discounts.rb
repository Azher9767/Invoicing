class CreateTaxAndDiscounts < ActiveRecord::Migration[7.1]
  def change
    create_table :tax_and_discounts do |t|
      t.string :name
      t.text :description
      t.string :td_type, default: "", null: false
      t.decimal :amount, default: "0.0", null: false
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
