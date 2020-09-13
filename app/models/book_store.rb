class BookStore < ApplicationRecord
  has_many :books
  has_many :open_hours
end
