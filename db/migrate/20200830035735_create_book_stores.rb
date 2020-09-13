class CreateBookStores < ActiveRecord::Migration[5.2]
  def change
    create_table :book_stores do |t|
      t.string :name
      t.float :cash_balance

      t.timestamps
    end
  end
end
