class CreateOpenHours < ActiveRecord::Migration[5.2]
  def change
    create_table :open_hours do |t|
      t.integer :book_store_id
      t.integer :day_of_week
      t.string :open_time
      t.string :close_time

      t.timestamps
    end
  end
end
