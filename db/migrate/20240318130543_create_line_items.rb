class CreateLineItems < ActiveRecord::Migration[7.1]
  def change
    create_table :line_items do |t|
      t.string :item_name
      t.float :unit_rate
      t.float :quantity
      t.belongs_to :invoice, null: false, foreign_key: true
      t.belongs_to :product, null: false, foreign_key: true
      t.string :unit

      t.timestamps
    end
  end
end
