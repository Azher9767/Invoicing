class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :category, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.float :unit_rate
      t.string :unit

      t.timestamps
    end
  end
end
