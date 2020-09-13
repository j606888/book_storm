class CreatePurchaseRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_records do |t|
      t.integer :user_id
      t.integer :book_id
      t.integer :book_store_id
      t.float :transaction_amount
      t.datetime :transaction_date

      t.timestamps
    end
  end
end
