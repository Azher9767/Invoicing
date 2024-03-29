class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :product_count
    
      t.timestamps
    end
  end
end
