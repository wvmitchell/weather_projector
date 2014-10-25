class FuturesFetcher
  include HTTParty
  base_uri 'http://www.xignite.com/xFutures.json'
  default_params '_Token' => ENV['XIGNITE_API_KEY']

  attr_reader :symbol, :month, :year

  def initialize(options={})
    @symbol = options[:symbol] || 'HO'
    @month = options[:month] || next_month.to_s
    @year = options[:year] || this_or_next_year.to_s
  end

  def get_historical_future(as_of_date)
    klass.get('/GetHistoricalFuture', query: {'Symbol' => symbol,
                                              'Month' => month,
                                              'Year'  => year,
                                              'AsOfDate' => as_of_date})
  end

  def get_historical_future_range(start_date, end_date)
    klass.get('/GetHistoricalFutureRange', query: {'Symbol' => symbol,
                                                   'Month' => month,
                                                   'Year'  => year,
                                                   'StartDate' => start_date,
                                                   'EndDate' => end_date})
  end

  def klass
    self.class
  end

  def next_month
    Time.now.month == 12 ? 1 : Time.now.month + 1
  end

  def this_or_next_year
    next_month == 1 ? Time.now.year + 1 : Time.now.year
  end

end
