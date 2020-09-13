class DataImport < ServiceCaller
  BOOK_STORE_DATA_PATH = "#{Rails.root}/book_store_data.json"
  USER_DATA_PATH = "#{Rails.root}/user_data.json"
  REGEX = / (?<open_time>\d+:?\d* (am|pm)) - (?<close_time>\d+:?\d* (am|pm))/
  WEEKDAY = %w[Sun Mon Tues Wed Thurs Fri Sat]

  def initialize
  end

  def call
    clean_db
    import_book_store
    import_user
  end

  def import_book_store
    f = File.read(BOOK_STORE_DATA_PATH)
    raw_data = JSON.parse(f)
    raw_data.each do |hash|
      book_store = BookStore.create(
        name: hash['storeName'],
        cash_balance: hash['cashBalance']
      )

      hash['books'].each do |book_hash|
        book = Book.create(
          book_store_id: book_store.id,
          name: book_hash['bookName'],
          price: book_hash['price']
        )
      end

      setup_open_hour(book_store.id, hash['openingHours'])
    end
  end

  def import_user
    f = File.read(USER_DATA_PATH)
    raw_data = JSON.parse(f)
    raw_data.each do |hash|
      user = User.create(
        id: hash['id'],
        name: hash['name'],
        cash_balance: hash['cashBalance']
      )

      hash['purchaseHistory'].each do |history_hash|
        book_store = BookStore.find_by(name: history_hash['storeName'])
        book = Book.find_by(name: history_hash['bookName'], book_store_id: book_store.id)
        PurchaseRecord.create(
          book_id: book.id,
          book_store_id: book_store.id,
          user_id: user.id,
          transaction_amount: history_hash['transactionAmount'],
          transaction_date: DateTime.strptime(history_hash['transactionDate'], "%m/%d/%Y %H:%M %p")
        )
      end
    end
  end

  private
  def clean_db
    clean_up_classes = [BookStore, Book, OpenHour, User, PurchaseRecord]
    clean_up_classes.each do |klass|
      klass.all.delete_all
    end
  end

  def setup_open_hour(book_store_id, opening_hours)
    opening_hours.split(' / ').each do |open_hour|
      parsed_time = REGEX.match open_hour
      open_time = parsed_time['open_time'].to_time.strftime("%H%M")
      close_time = parsed_time['close_time'].to_time.strftime("%H%M")
      close_time = (close_time.to_i + 2400).to_s if close_time < open_time  
      weekdays = open_hour.gsub(parsed_time[0], '')
      if weekdays.include?(', ')
        weekdays = weekdays.split(', ')
        weekdays.each do |weekday|
          OpenHour.create(book_store_id: book_store_id, day_of_week: WEEKDAY.index(weekday), open_time: open_time, close_time: close_time)
        end
      elsif weekdays.include?(' - ')
        weekdays = weekdays.split(' - ')
        current_weekday = WEEKDAY.index(weekdays.first)
        end_weekday = WEEKDAY.index(weekdays.last)
        loop do
          OpenHour.create(book_store_id: book_store_id, day_of_week: current_weekday, open_time: open_time, close_time: close_time)
          break if current_weekday == end_weekday
          current_weekday = (current_weekday + 1) % 7
        end
      elsif WEEKDAY.index(weekdays)
        OpenHour.create(book_store_id: book_store_id, day_of_week: WEEKDAY.index(weekdays), open_time: open_time, close_time: close_time)
      else
        raise 'Unknown type'
      end
    end
  end
end