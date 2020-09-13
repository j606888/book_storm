class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |t|
      t.integer :book_store_id
      t.string :name
      t.float :price

      t.timestamps
    end
  end
end
